extends RefCounted

const SCHEMA_VERSION: int = 1
const MAX_DOCUMENT_BYTES: int = 262144
const MAX_REQUESTS: int = 32
const DEFAULT_DIRECTORY: String = "user://godot-lab/documents"

var directory: String = DEFAULT_DIRECTORY
var storage_namespace: String = "demo"


func configure(value: String) -> Dictionary:
	if not _is_safe_id(value):
		return _failure("invalid_namespace", "Namespace must be a safe identifier.")
	storage_namespace = value
	return {"ok": true, "code": "configured", "namespace": storage_namespace}


func save(id: String, document: Dictionary, expected_revision: int = -1,
		request_id: String = "") -> Dictionary:
	if not _is_safe_id(id):
		return _failure("invalid_id", "Document ID must be a safe identifier.")
	if expected_revision < -1:
		return _failure("invalid_revision", "Expected revision must be -1 or greater.")
	if not request_id.is_empty() and not _is_safe_id(request_id):
		return _failure("invalid_request_id", "Request ID must be a safe identifier.")
	var payload_text: String = JSON.stringify(document)
	if payload_text.to_utf8_buffer().size() > MAX_DOCUMENT_BYTES:
		return _failure("document_too_large", "Document exceeds the 256 KiB limit.")
	var fingerprint: String = _sha256(payload_text.to_utf8_buffer())
	var path: String = _document_path(id)
	var current: Dictionary = _read_document(path)
	if not current.get("ok", false):
		if current.get("code", "") != "not_found":
			return current
		current = {"ok": true, "revision": 0, "document": {}, "requests": []}
	var current_revision: int = current["revision"]
	var requests: Array[Dictionary] = []
	for stored_request: Variant in current["requests"]:
		if stored_request is Dictionary:
			requests.append(stored_request)
	if not request_id.is_empty():
		for entry: Dictionary in requests:
			if entry.get("id", "") == request_id:
				if entry.get("fingerprint", "") != fingerprint:
					return _failure("request_conflict", "Request ID was already used for different content.")
				return {"ok": true, "code": "replayed", "message": "Earlier request result returned.",
					"revision": entry.get("revision", current_revision), "request_id": request_id,
					"replayed": true, "document": current.get("document", {})}
	if expected_revision != -1 and expected_revision != current_revision:
		return _failure("revision_conflict", "Document revision changed before this write.",
			{"revision": current_revision})
	var next_revision: int = current_revision + 1
	var next_requests: Array[Dictionary] = requests.duplicate(true)
	if not request_id.is_empty():
		next_requests.append({"id": request_id, "fingerprint": fingerprint, "revision": next_revision})
	while next_requests.size() > MAX_REQUESTS:
		next_requests.pop_front()
	var encoded: String = JSON.stringify({"schema_version": SCHEMA_VERSION,
		"revision": next_revision, "payload": document, "requests": next_requests}, "\t")
	if encoded.to_utf8_buffer().size() > MAX_DOCUMENT_BYTES:
		return _failure("document_too_large", "Document and retry history exceed the 256 KiB limit.")
	var write_error: Error = _atomic_write(path, encoded)
	if write_error != OK:
		return _failure("write_failed", "Could not atomically publish document (error %d)." % write_error)
	return {"ok": true, "code": "saved", "message": "Document saved.", "revision": next_revision,
		"request_id": request_id, "replayed": false, "document": document.duplicate(true)}


func load_document(id: String) -> Dictionary:
	if not _is_safe_id(id):
		return _failure("invalid_id", "Document ID must be a safe identifier.")
	var result: Dictionary = _read_document(_document_path(id))
	if not result.get("ok", false):
		return result
	return {"ok": true, "code": "loaded", "message": "Document loaded.",
		"revision": result["revision"], "document": result["document"].duplicate(true)}


func reset_demo() -> Dictionary:
	if storage_namespace != "demo":
		return _failure("reset_scope_denied", "Demo reset is available only in the demo namespace.")
	var demo_directory: String = ProjectSettings.globalize_path(directory.path_join("demo"))
	if not demo_directory.begins_with(ProjectSettings.globalize_path(directory) + "/"):
		return _failure("reset_scope_denied", "Resolved demo directory escaped the document root.")
	if not DirAccess.dir_exists_absolute(demo_directory):
		return {"ok": true, "code": "reset", "removed": 0}
	var dir: DirAccess = DirAccess.open(demo_directory)
	if dir == null:
		return _failure("reset_failed", "Could not open the owned demo directory.")
	var removed: int = 0
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while not name.is_empty():
		if not dir.current_is_dir() and (name.ends_with(".json") or name.ends_with(".pending")):
			var remove_error: Error = dir.remove(name)
			if remove_error != OK:
				dir.list_dir_end()
				return _failure("reset_failed", "Could not remove owned document file (error %d)." % remove_error)
			removed += 1
		name = dir.get_next()
	dir.list_dir_end()
	return {"ok": true, "code": "reset", "removed": removed}


func _read_document(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _failure("not_found", "Document does not exist.")
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _failure("read_failed", "Could not read document (error %d)." % FileAccess.get_open_error())
	if file.get_length() > MAX_DOCUMENT_BYTES:
		file.close()
		return _failure("document_too_large", "Stored document exceeds the 256 KiB limit.")
	var text: String = file.get_as_text()
	file.close()
	var parser: JSON = JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		return _failure("malformed_document", "Stored document is malformed; existing bytes were preserved.")
	var envelope: Dictionary = parser.data
	if envelope.get("schema_version") != SCHEMA_VERSION:
		return _failure("unsupported_schema", "Stored document schema is unknown or newer; existing bytes were preserved.")
	if not _is_integer_number(envelope.get("revision", null)) or int(envelope["revision"]) < 1:
		return _failure("malformed_document", "Stored document revision is invalid.")
	if not envelope.get("payload") is Dictionary or not envelope.get("requests", []) is Array:
		return _failure("malformed_document", "Stored document payload or retry history is invalid.")
	var request_list: Array[Dictionary] = []
	for entry: Variant in envelope.get("requests", []):
		if not entry is Dictionary or not entry.get("id", "") is String or not entry.get("fingerprint", "") is String or not _is_integer_number(entry.get("revision", null)):
			return _failure("malformed_document", "Stored retry history is invalid.")
		request_list.append(entry)
	return {"ok": true, "revision": int(envelope["revision"]),
		"document": envelope["payload"], "requests": request_list}


func _atomic_write(path: String, contents: String) -> Error:
	var absolute_directory: String = ProjectSettings.globalize_path(path.get_base_dir())
	var make_error: Error = DirAccess.make_dir_recursive_absolute(absolute_directory)
	if make_error != OK:
		return make_error
	var pending_path: String = path + ".pending"
	var pending_absolute: String = ProjectSettings.globalize_path(pending_path)
	var file: FileAccess = FileAccess.open(pending_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(contents)
	file.flush()
	var flush_error: Error = file.get_error()
	file.close()
	if flush_error != OK:
		return flush_error
	return DirAccess.rename_absolute(pending_absolute, ProjectSettings.globalize_path(path))


func _document_path(id: String) -> String:
	return directory.path_join(storage_namespace).path_join(id + ".json")


func _is_safe_id(value: String) -> bool:
	if value.is_empty() or value.length() > 64:
		return false
	for index: int in range(value.length()):
		var codepoint: int = value.unicode_at(index)
		var allowed: bool = (codepoint >= 48 and codepoint <= 57) or (codepoint >= 65 and codepoint <= 90) or (codepoint >= 97 and codepoint <= 122) or codepoint == 45 or codepoint == 95
		if not allowed or (index == 0 and (codepoint == 45 or codepoint == 95)):
			return false
	return true


func _sha256(bytes: PackedByteArray) -> String:
	var context: HashingContext = HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()


func _is_integer_number(value: Variant) -> bool:
	if not (value is int or value is float):
		return false
	return floor(float(value)) == float(value)


func _failure(code: String, message: String, extra: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {"ok": false, "code": code, "message": message}
	result.merge(extra, true)
	return result
