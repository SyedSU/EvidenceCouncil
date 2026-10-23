extends SceneTree
var failures=0
func check(ok:bool,message:String):
 if not ok:failures+=1;push_error(message)
func _initialize():call_deferred("run")
func run():
 var domain=load("res://scripts/council.gd").new();domain.assign("Transport fixture only")
 var client=load("res://scripts/local_inference.gd").new();root.add_child(client)
 check(not client.generate(domain,"researcher","https://example.com","fixture").is_empty(),"Reject cloud before HTTP")
 for mode in ["valid","malformed","empty","http_error","redirect","oversized"]:
  check(client.generate(domain,"researcher","http://127.0.0.1:18946",mode).is_empty(),"Start "+mode)
  var result=await client.finished
  check(result[0]=="researcher","Preserve requested role")
  if mode=="valid":check(result[1]=="SYNTHETIC TRANSPORT FIXTURE" and result[2].is_empty(),"Parse bounded response")
  else:check(result[1].is_empty() and not result[2].is_empty(),"Reject "+mode)
 check(client.generate(domain,"writer","http://127.0.0.1:18946","slow").is_empty(),"Start cancellable request")
 check(not client.generate(domain,"planner","http://127.0.0.1:18946","valid").is_empty(),"Reject overlapping generation")
 var canceled=[]
 client.finished.connect(func(role,content,error):canceled.append([role,content,error]))
 client.cancel()
 check(canceled.size()==1 and canceled[0][0]=="writer" and canceled[0][1].is_empty() and canceled[0][2].contains("Canceled"),"Cancel returns no accepted draft")
 await create_timer(0.2).timeout
 check(canceled.size()==1,"Canceled request produces no late contribution")
 client.queue_free();await process_frame
 print("TRANSPORT_FAILURES=",failures);quit(1 if failures else 0)
