extends SceneTree
var failures=0
func check(ok:bool,message:String):
 if not ok:failures+=1;push_error(message)
func _initialize():call_deferred("run")
func run():
 var ui=load("res://main.tscn").instantiate();root.add_child(ui);await process_frame
 check(ui.editors.size()==4,"Four role editors available")
 ui.council.assign("Native interface task");ui.refresh()
 ui.editors.researcher.text="Manual evidence";ui.editors.researcher.text_changed.emit()
 check(ui.council.data.contributions.researcher.text=="Manual evidence","Editor updates real domain")
 ui.final_edit.text="Native interface result";ui.final_edit.text_changed.emit()
 check(ui.council.approve().is_empty(),"UI final reaches approval")
 ui.assignment.text="Uncommitted different assignment";ui.assignment.text_changed.emit()
 check(not ui.council.data.approved,"Assignment edits must revoke approval immediately")
 check(ui.council.data.assignment=="Uncommitted different assignment","Assignment editor matches domain")
 ui.pending_action="open";ui.dirty=false
 ui.selected_file("user://missing-ui-fixture.json")
 check(ui.status.text.length()>0 and ui.council.blocked,"UI reports failed open and blocks overwrite")
 ui._new_workspace()
 check(not ui.council.blocked and ui.council.data.assignment.is_empty(),"New workspace recovers from failed open")
 ui.assignment.text="Manual demonstration — compare an urban tree proposal";ui.assignment.text_changed.emit()
 for role in ui.council.ROLES:
  ui.editors[role].text="MANUAL DEMONSTRATION: "+role+" contribution; no AI model used."
  ui.editors[role].text_changed.emit()
 ui.final_edit.text="Manual demonstration final: review local evidence before choosing planting sites.";ui.final_edit.text_changed.emit()
 for control in ui.find_children("*","Button",true,false):
  if control.text=="Approve this exact final result":control.pressed.emit()
 check(ui.council.data.approved,"Approval button approves exact result")
 ui.path.text="user://ui-proof-"+str(Time.get_ticks_usec())+".json";ui.save_workspace()
 check(not ui.dirty,"Native UI save clears dirty state")
 ui.pending_action="export";ui.selected_file("user://ui-approved.md")
 check(FileAccess.get_file_as_string("user://ui-approved.md").contains(ui.final_edit.text),"UI export has approved result")
 ui.pending_action="open";ui.selected_file(ui.path.text)
 check(ui.council.data.approved and ui.final_edit.text==ui.council.data.final,"UI reopens approved result")
 for argument in OS.get_cmdline_user_args():
  if argument.begins_with("--capture="):
   await process_frame;await process_frame
   var image=root.get_texture().get_image()
   var capture=argument.trim_prefix("--capture=")
   check(image.save_png(capture)==OK,"Capture rendered native scene")
   ui.get_child(1).scroll_vertical=10000
   await process_frame;await process_frame
   check(root.get_texture().get_image().save_png(capture.trim_suffix(".png")+"-approval.png")==OK,"Capture final approval and export status")
 ui.queue_free();await process_frame
 print("UI_FAILURES=",failures);quit(1 if failures else 0)
