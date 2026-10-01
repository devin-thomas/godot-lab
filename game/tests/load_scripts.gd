extends SceneTree


func _initialize() -> void:
	var paths: Array[String] = []
	_collect("res://", paths)
	paths.sort()
	var success: bool = true
	for path: String in paths:
		var script: GDScript = load(path)
		if script == null or not script.can_instantiate():
			success = false
	print("SCRIPT_GATE " + ("PASS" if success else "FAIL"))
	quit(0 if success else 1)


func _collect(directory: String, paths: Array[String]) -> void:
	for file: String in DirAccess.get_files_at(directory):
		if file.ends_with(".gd"):
			paths.append(directory.path_join(file))
	for child: String in DirAccess.get_directories_at(directory):
		if child.begins_with(".") or child == "addons":
			continue
		_collect(directory.path_join(child), paths)
