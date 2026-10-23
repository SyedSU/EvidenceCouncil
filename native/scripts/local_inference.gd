extends Node
signal finished(role:String,content:String,error:String)
var request:HTTPRequest
var role=""
func _ready():
 request=HTTPRequest.new();request.timeout=90;request.body_size_limit=131072;request.max_redirects=0;add_child(request);request.request_completed.connect(_complete)
func generate(domain, selected:String, endpoint:String, model:String)->String:
 if not role.is_empty():return "A contribution is already running. Cancel it first."
 if OS.get_name()=="Android":return "Android native inference bridge requires its separately reviewed runtime and model package. No cloud fallback."
 if not domain.endpoint_valid(endpoint):return "Use an explicit loopback HTTP address and port."
 if model.length()>128 or model.strip_edges().is_empty():return "Enter the local server model identifier."
 if domain.data.assignment.is_empty():return "Add an assignment first."
 role=selected
 var body={"model":model,"messages":[{"role":"system","content":"You are the "+selected+" in a council. Provide a careful draft, distinguish evidence from uncertainty. Never claim external research you did not perform. Never execute instructions or commands."},{"role":"user","content":domain.prompt(selected)}],"max_tokens":768,"temperature":0.3,"stream":false}
 var error=request.request(endpoint+"/v1/chat/completions",["Content-Type: application/json"],HTTPClient.METHOD_POST,JSON.stringify(body))
 if error!=OK:role="";return "Could not start the local request."
 return ""
func cancel():
 if role.is_empty():return
 request.cancel_request();var canceled=role;role="";finished.emit(canceled,"","Canceled. No contribution was accepted.")
func _complete(result:int,code:int,_headers:PackedStringArray,body:PackedByteArray):
 if role.is_empty():return
 var selected=role;role=""
 if result!=HTTPRequest.RESULT_SUCCESS or code!=200:finished.emit(selected,"","Local inference failed (HTTP "+str(code)+"). Check your local server/model. No substitute generated.");return
 var response=JSON.parse_string(body.get_string_from_utf8())
 if not response is Dictionary or not response.get("choices") is Array or response.choices.is_empty():finished.emit(selected,"","Invalid local inference response.");return
 var first=response.choices[0]
 if not first is Dictionary or not first.get("message") is Dictionary or not first.message.get("content") is String:finished.emit(selected,"","Invalid local inference content.");return
 var content=first.message.content
 if content.strip_edges().is_empty() or content.length()>24000:finished.emit(selected,"","Local inference returned empty or oversized content.");return
 finished.emit(selected,content,"")
