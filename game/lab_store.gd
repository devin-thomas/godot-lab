extends RefCounted

const PATH: String = "user://godot-lab/progress.json"
const IDS: Array[String] = ["motion", "physics", "navigation", "materials", "audio", "persistence"]
var completed: Array[String] = []
var reduced_motion: bool = false
var muted: bool = false
var last_error: String = ""
var path: String = PATH


func load_progress() -> Error:
	completed.clear()
	last_error = ""
	if not FileAccess.file_exists(path):
		return OK
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _error("Cannot read lab progress", FileAccess.get_open_error())
	var parser: JSON = JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return _error("Malformed progress: " + parser.get_error_message(), ERR_PARSE_ERROR)
	var data: Variant = parser.data
	if not data is Dictionary:
		return _error("Progress must be an object", ERR_INVALID_DATA)
	if data.get("schema_version") != 1 or not data.get("completed") is Array:
		return _error("Unsupported progress schema", ERR_INVALID_DATA)
	if not data.get("reduced_motion", false) is bool or not data.get("muted", false) is bool:
		return _error("Invalid comfort settings", ERR_INVALID_DATA)
	var parsed_completed: Array[String] = []
	for id: Variant in data["completed"]:
		if not id is String or not IDS.has(id):
			return _error("Unknown completed lab", ERR_INVALID_DATA)
		if not parsed_completed.has(id):
			parsed_completed.append(id)
	completed = parsed_completed
	reduced_motion = data.get("reduced_motion", false)
	muted = data.get("muted", false)
	return OK


func save_progress() -> Error:
	if not last_error.is_empty() and FileAccess.file_exists(path):
		return ERR_INVALID_DATA
	last_error = ""
	var directory: String = ProjectSettings.globalize_path(path.get_base_dir())
	var result: Error = DirAccess.make_dir_recursive_absolute(directory)
	if result != OK:
		return _error("Cannot create lab save directory", result)
	var pending: String = path + ".pending"
	var file: FileAccess = FileAccess.open(pending, FileAccess.WRITE)
	if file == null:
		return _error("Cannot write lab progress", FileAccess.get_open_error())
	file.store_string(JSON.stringify({"schema_version": 1, "completed": completed,
		"reduced_motion": reduced_motion, "muted": muted}, "\t"))
	file.flush()
	result = file.get_error()
	file.close()
	if result != OK:
		return _error("Cannot flush lab progress", result)
	result = DirAccess.rename_absolute(ProjectSettings.globalize_path(pending),
		ProjectSettings.globalize_path(path))
	if result != OK:
		return _error("Cannot commit lab progress", result)
	return OK


func complete_lab(id: String) -> Error:
	if not IDS.has(id):
		return _error("Unknown lab: " + id, ERR_INVALID_PARAMETER)
	if not completed.has(id):
		completed.append(id)
	return save_progress()


func _error(message: String, code: Error) -> Error:
	last_error = message
	push_warning(message)
	return code
