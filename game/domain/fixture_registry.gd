extends RefCounted

const MAX_FIXTURE_BYTES: int = 262144
const MAX_STAGED_BYTES: int = 524288
const MAX_FIXTURES: int = 64
const MAX_STAGED_FIXTURES: int = 16

var fixture_namespace: String = "demo"
var _fixtures: Dictionary = {}
var _fixture_payloads: Dictionary = {}
var _staged: Dictionary = {}


func configure(value: String) -> Dictionary:
	if not _is_safe_id(value):
		return _failure("invalid_namespace", "Namespace must be a safe identifier.")
	if fixture_namespace != value:
		_fixtures.clear()
		_fixture_payloads.clear()
		_staged.clear()
	fixture_namespace = value
	return {"ok": true, "code": "configured", "namespace": fixture_namespace}


func register_fixture(id: String, manifest: Dictionary) -> Dictionary:
	if not _is_safe_id(id):
		return _failure("invalid_id", "Fixture ID must be a safe identifier.")
	if not manifest.get("source", "") is String or str(manifest.get("source", "")).strip_edges().is_empty():
		return _failure("missing_provenance", "Fixture provenance source is required.")
	if not manifest.get("license", "") is String or str(manifest.get("license", "")).strip_edges().is_empty():
		return _failure("missing_license", "Fixture license is required.")
	if not manifest.has("payload"):
		return _failure("missing_payload", "Fixture payload is required to compute its manifest.")
	var payload: PackedByteArray = _payload_bytes(manifest["payload"])
	if payload.is_empty():
		return _failure("invalid_payload", "Fixture payload must be nonempty text or bytes.")
	if payload.size() > MAX_FIXTURE_BYTES:
		return _failure("fixture_too_large", "Fixture exceeds the 256 KiB limit.")
	if _contains_native_signature(payload):
		return _failure("native_payload_rejected", "Native executable payloads are not admitted.")
	if _fixtures.size() >= MAX_FIXTURES and not _fixtures.has(id):
		return _failure("registry_full", "Fixture registry reached its capacity.")
	var digest: String = _sha256(payload)
	if manifest.has("sha256") and str(manifest["sha256"]).to_lower() != digest:
		return _failure("hash_mismatch", "Supplied fixture hash does not match its bytes.")
	var version: int = int(manifest.get("version", 1))
	if version < 1:
		return _failure("invalid_version", "Fixture version must be positive.")
	var registered: Dictionary = {"id": id, "namespace": fixture_namespace, "version": version,
		"source": manifest["source"], "license": manifest["license"], "sha256": digest,
		"byte_count": payload.size(), "limits": {"max_bytes": MAX_FIXTURE_BYTES},
		"network_source": false}
	_fixtures[id] = registered
	_fixture_payloads[id] = payload
	return {"ok": true, "code": "registered", "message": "Original fixture registered.",
		"manifest": registered.duplicate(true)}


func list_fixtures() -> Dictionary:
	var entries: Array[Dictionary] = []
	for key: Variant in _fixtures.keys():
		entries.append(_fixtures[key].duplicate(true))
	entries.sort_custom(func(left: Dictionary, right: Dictionary) -> bool: return str(left["id"]) < str(right["id"]))
	return {"ok": true, "code": "listed", "namespace": fixture_namespace, "fixtures": entries}


func probe_fixture(id: String) -> Dictionary:
	if not _fixtures.has(id):
		return _failure("not_found", "Fixture is not registered in this namespace.")
	return {"ok": true, "code": "available", "manifest": _fixtures[id].duplicate(true),
		"readiness": "ready", "route": "original_local_fixture"}


func load_fixture(id: String) -> Dictionary:
	if not _fixture_payloads.has(id):
		return _failure("not_found", "Fixture bytes are not registered in this namespace.")
	return {"ok": true, "code": "loaded", "manifest": _fixtures[id].duplicate(true),
		"payload": _fixture_payloads[id].duplicate()}


func stage_import(id: String, payload: PackedByteArray) -> Dictionary:
	if not _is_safe_id(id):
		return _failure("invalid_id", "Staged fixture ID must be a safe identifier.")
	if payload.is_empty() or payload.size() > MAX_FIXTURE_BYTES:
		return _failure("fixture_too_large", "Staged payload must contain 1 to 256 KiB.")
	if _contains_native_signature(payload):
		return _failure("native_payload_rejected", "Native executable payloads are not admitted.")
	if not _valid_portable_json(payload):
		return _failure("malformed_import", "Staged imports must be valid bounded portable JSON.")
	if _contains_unsafe_path(JSON.parse_string(payload.get_string_from_utf8())):
		return _failure("unsafe_path", "Staged import contains an absolute or traversing path.")
	var total_bytes: int = 0
	for entry: Dictionary in _staged.values():
		total_bytes += int(entry["byte_count"])
	if not _staged.has(id) and _staged.size() >= MAX_STAGED_FIXTURES:
		return _failure("staging_full", "Staging namespace reached its fixture limit.")
	if total_bytes - int(_staged.get(id, {}).get("byte_count", 0)) + payload.size() > MAX_STAGED_BYTES:
		return _failure("staging_budget_exceeded", "Staging namespace exceeds its 512 KiB budget.")
	var entry: Dictionary = {"id": id, "namespace": fixture_namespace, "sha256": _sha256(payload),
		"byte_count": payload.size(), "format": "portable-json", "state": "staged"}
	_staged[id] = entry
	return {"ok": true, "code": "staged", "manifest": entry.duplicate(true)}


func clear_staging() -> Dictionary:
	var removed: int = _staged.size()
	_staged.clear()
	return {"ok": true, "code": "staging_cleared", "removed": removed, "namespace": fixture_namespace}


func _valid_portable_json(payload: PackedByteArray) -> bool:
	var parser: JSON = JSON.new()
	if parser.parse(payload.get_string_from_utf8()) != OK or not parser.data is Dictionary:
		return false
	if parser.data.get("schema_version") != 1:
		return false
	if not parser.data is Dictionary:
		return false
	return _nested_values_within_limit(parser.data, 0)


func _nested_values_within_limit(value: Variant, depth: int) -> bool:
	if depth > 32:
		return false
	if value is Dictionary:
		for key: Variant in value.keys():
			if not key is String or str(key).to_utf8_buffer().size() > 256:
				return false
			if not _nested_values_within_limit(value[key], depth + 1):
				return false
	elif value is Array:
		if value.size() > 4096:
			return false
		for child: Variant in value:
			if not _nested_values_within_limit(child, depth + 1):
				return false
	elif value is String and value.to_utf8_buffer().size() > MAX_FIXTURE_BYTES:
		return false
	return true


func _contains_unsafe_path(value: Variant) -> bool:
	if value is Dictionary:
		for key: Variant in value.keys():
			var key_text: String = str(key).to_lower()
			var child: Variant = value[key]
			if (key_text == "path" or key_text.ends_with("_path") or key_text == "filename") and child is String:
				if _is_absolute_or_traversing(str(child)):
					return true
			if _contains_unsafe_path(child):
				return true
	elif value is Array:
		for child: Variant in value:
			if _contains_unsafe_path(child):
				return true
	return false


func _is_absolute_or_traversing(value: String) -> bool:
	var normalized: String = value.replace("\\", "/")
	if normalized.begins_with("/") or normalized.contains(":"):
		return true
	for segment: String in normalized.split("/"):
		if segment == ".." or segment == ".":
			return true
	return false


func _contains_native_signature(bytes: PackedByteArray) -> bool:
	if bytes.size() >= 2 and bytes[0] == 77 and bytes[1] == 90:
		return true
	if bytes.size() >= 4 and bytes[0] == 127 and bytes[1] == 69 and bytes[2] == 76 and bytes[3] == 70:
		return true
	if bytes.size() >= 4 and bytes[0] == 0xCF and bytes[1] == 0xFA and bytes[2] == 0xED and bytes[3] == 0xFE:
		return true
	if bytes.size() >= 4 and bytes[0] == 0xFE and bytes[1] == 0xED and bytes[2] == 0xFA and bytes[3] == 0xCF:
		return true
	return false


func _payload_bytes(payload: Variant) -> PackedByteArray:
	if payload is PackedByteArray:
		return payload.duplicate()
	if payload is String:
		return str(payload).to_utf8_buffer()
	return PackedByteArray()


func _sha256(bytes: PackedByteArray) -> String:
	var context: HashingContext = HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()


func _is_safe_id(value: String) -> bool:
	if value.is_empty() or value.length() > 64:
		return false
	for index: int in range(value.length()):
		var codepoint: int = value.unicode_at(index)
		var allowed: bool = (codepoint >= 48 and codepoint <= 57) or (codepoint >= 65 and codepoint <= 90) or (codepoint >= 97 and codepoint <= 122) or codepoint == 45 or codepoint == 95
		if not allowed or (index == 0 and (codepoint == 45 or codepoint == 95)):
			return false
	return true


func _failure(code: String, message: String) -> Dictionary:
	return {"ok": false, "code": code, "message": message}
