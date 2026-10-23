extends RefCounted
# Export only to a new regular path; reject symlink components and preserve existing bytes.
static func write_new(path:String,bytes:PackedByteArray,files)->String:
 var absolute=ProjectSettings.globalize_path(path).simplify_path()
 if not absolute.is_absolute_path():return "Choose an absolute export destination."
 var cursor=absolute
 while not cursor.get_file().is_empty():
  var parent=cursor.get_base_dir()
  var directory=DirAccess.open(parent)
  if directory==null:return "Export folder is unavailable."
  if directory.is_link(cursor.get_file()):return "Choose an export path without symbolic links."
  if cursor==parent:break
  cursor=parent
 if FileAccess.file_exists(absolute) or DirAccess.dir_exists_absolute(absolute):return "Choose a new filename; export preserves existing files."
 if not files.lease(absolute,true):return "Export target is busy."
 var error=""
 if FileAccess.file_exists(absolute) or DirAccess.dir_exists_absolute(absolute):error="Export target already exists."
 else:
  var stage=files.temporary(absolute);error=files.store_checked(stage,bytes)
  if error.is_empty() and files.replace(stage,absolute)!=OK:error="Export could not be durably committed. Inspect the destination and recovery stage: "+stage
  elif not error.is_empty():files.cleanup(stage)
 if not files.lease(absolute,false):return "Export lock release failed. Inspect the destination before retrying."
 return error
