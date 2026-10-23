extends Control
var council=preload("res://scripts/council.gd").new()
var inference=preload("res://scripts/local_inference.gd").new()
var editors={}
var assignment:TextEdit
var final_edit:TextEdit
var status:Label
var endpoint:LineEdit
var model:LineEdit
var path:LineEdit
var role_picker:OptionButton
var tabs:TabContainer
var dialog:FileDialog
var pending_action=""
var dirty=false
var syncing=false
func _ready():
 get_tree().auto_accept_quit=false
 var theme=Theme.new();theme.default_font_size=18
 theme.set_color("font_color","Label",Color("f6efd9"));theme.set_color("font_color","Button",Color("f6efd9"))
 var panel=StyleBoxFlat.new();panel.bg_color=Color("193e36");theme.set_stylebox("panel","PanelContainer",panel)
 self.theme=theme
 var background=ColorRect.new();background.color=Color("112b26");background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(background)
 var scroll=ScrollContainer.new();scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(scroll)
 var box=VBoxContainer.new();box.size_flags_horizontal=Control.SIZE_EXPAND_FILL;box.add_theme_constant_override("separation",12);scroll.add_child(box)
 label(box,"EvidenceCouncil  •  Local team workspace",26)
 label(box,"Researcher · Writer · Reviewer · Planner — compare drafts, edit and explicitly approve.")
 var toolbar=HFlowContainer.new();box.add_child(toolbar)
 button(toolbar,"New workspace",_new_workspace)
 button(toolbar,"Open…",func():choose("open"))
 button(toolbar,"Save",save_workspace)
 button(toolbar,"Save as…",func():choose("save"))
 button(toolbar,"Export approved…",func():choose("export"))
 path=LineEdit.new();path.text="user://workspace.json";path.placeholder_text="Workspace path";path.custom_minimum_size=Vector2(250,48);toolbar.add_child(path)
 label(box,"Assignment")
 assignment=editor(box,12000,110)
 assignment.text_changed.connect(func():
  if not syncing:
   inference.cancel();council.data.assignment=assignment.text;council.invalidate();dirty=true;approval_status())
 button(box,"Set assignment / reset contributions",func():
  inference.cancel()
  var error=council.assign(assignment.text)
  if error.is_empty():dirty=true;refresh()
  report(error,"Assignment set. Add manual contributions or use a running local model."))
 var connection=HFlowContainer.new();box.add_child(connection)
 endpoint=LineEdit.new();endpoint.text="http://127.0.0.1:8080";endpoint.custom_minimum_size=Vector2(290,48);connection.add_child(endpoint)
 model=LineEdit.new();model.text="local-model";model.placeholder_text="Local server model id";model.custom_minimum_size=Vector2(200,48);connection.add_child(model)
 role_picker=OptionButton.new();role_picker.custom_minimum_size.y=48
 for role in council.ROLES:role_picker.add_item(role.capitalize())
 connection.add_child(role_picker)
 button(connection,"Generate contribution",generate)
 button(connection,"Cancel generation",func():inference.cancel())
 label(box,"Local inference only. Start your reviewed llama-server separately. Drafts cannot run commands.")
 tabs=TabContainer.new();tabs.custom_minimum_size.y=270;box.add_child(tabs)
 for role in council.ROLES:
  var content=VBoxContainer.new();content.name=role.capitalize();tabs.add_child(content)
  label(content,"Editable "+role+" contribution")
  var text=editor(content,24000,190);editors[role]=text
  text.text_changed.connect(func():
   if not syncing:council.contribute(role,text.text,"manual");dirty=true;approval_status())
 label(box,"Final result — assemble and edit the result you want to approve")
 final_edit=editor(box,48000,210)
 final_edit.text_changed.connect(func():
  if not syncing:council.set_final(final_edit.text);dirty=true;approval_status())
 button(box,"Approve this exact final result",func():
  var error=council.approve()
  if error.is_empty():dirty=true
  report(error,"Approved this exact text. Any contribution or final edit revokes approval."))
 status=Label.new();status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;status.custom_minimum_size.y=70;box.add_child(status)
 dialog=FileDialog.new();dialog.access=FileDialog.ACCESS_FILESYSTEM;dialog.use_native_dialog=true;dialog.file_selected.connect(selected_file);add_child(dialog)
 add_child(inference);inference.finished.connect(received)
 report("","Ready. Create or open a workspace. Nothing is sent to cloud services.")
func label(parent:Node,value:String,size:int=18):
 var item=Label.new();item.text=value;item.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;item.add_theme_font_size_override("font_size",size);parent.add_child(item)
func button(parent:Node,value:String,action:Callable):
 var item=Button.new();item.text=value;item.custom_minimum_size.y=48;item.pressed.connect(action);parent.add_child(item)
func editor(parent:Node,limit:int,height:int)->TextEdit:
 var item=TextEdit.new();item.custom_minimum_size=Vector2(0,height);item.size_flags_horizontal=Control.SIZE_EXPAND_FILL;item.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY;parent.add_child(item)
 item.text_changed.connect(func():
  if item.text.length()>limit:item.text=item.text.left(limit))
 return item
func report(error:String,success:String=""):
 status.text=error if not error.is_empty() else success
 status.modulate=Color("f3bf83") if not error.is_empty() else Color("f6efd9")
func approval_status():
 report("","Unapproved changes. Save your workspace; explicitly approve before exporting.")
func refresh():
 syncing=true;assignment.text=council.data.assignment;final_edit.text=council.data.final
 for role in council.ROLES:editors[role].text=council.data.contributions.get(role,{}).get("text","")
 syncing=false
func generate():
 var error=inference.generate(council,council.ROLES[role_picker.selected],endpoint.text,model.text)
 report(error,"Generating with your local model… You can cancel.")
func received(role:String,content:String,error:String):
 if not error.is_empty():report(error);return
 var result=council.contribute(role,content,"local_ai");dirty=true;refresh();report(result,"Local AI draft received for "+role+". Verify and edit before approval.")
func save_workspace():
 var error=council.save(path.text)
 if error.is_empty():dirty=false
 report(error,"Workspace saved to "+path.text)
func choose(action:String):
 if action=="open" and dirty:report("Save current changes before opening another workspace.");return
 pending_action=action;dialog.file_mode=FileDialog.FILE_MODE_OPEN_FILE if action=="open" else FileDialog.FILE_MODE_SAVE_FILE
 dialog.filters=PackedStringArray(["*.md ; Approved Markdown"]) if action=="export" else PackedStringArray(["*.json ; Council workspace"])
 dialog.popup_centered_ratio(0.8)
func selected_file(value:String):
 if pending_action=="export":report(council.export_markdown(value),"Approved result exported to "+value);return
 inference.cancel()
 if pending_action=="open":
  var error=council.open(value);path.text=value;refresh();dirty=false;report(error,"Workspace opened. "+("Approved result retained." if council.data.approved else "Result is unapproved."))
 else:path.text=value;save_workspace()
func _new_workspace():
 if dirty:report("Save current changes before creating a new workspace.");return
 inference.cancel();council=preload("res://scripts/council.gd").new();path.text="user://workspace.json";refresh();report("","New workspace. Use Save as to preserve an existing file.")
func _notification(what):
 if what==NOTIFICATION_WM_CLOSE_REQUEST:
  if dirty:report("Unsaved changes. Save successfully before closing.")
  else:inference.cancel();get_tree().quit()
