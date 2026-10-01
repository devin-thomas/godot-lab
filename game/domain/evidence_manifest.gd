extends RefCounted

const SCHEMA_VERSION: int = 1
const MAX_GATES: int = 128
const MAX_ARTIFACTS: int = 128
const MAX_BYTES: int = 262144
const CHANNELS: Array[String] = ["logic", "pixels", "audio", "provider", "export", "human", "device", "tool", "transport", "editor", "native", "profile"]
const STATUSES: Array[String] = ["passed", "failed", "pending", "unavailable"]


func build(context: Dictionary, gates: Array[Dictionary], artifacts: Array[Dictionary] = []) -> Dictionary:
	var manifest: Dictionary = {"schema_version": SCHEMA_VERSION, "context": context.duplicate(true), "gates": gates.duplicate(true), "artifacts": artifacts.duplicate(true)}
	var validation: Dictionary = validate(manifest, context)
	if not validation["ok"]:
		return validation
	return {"ok": true, "code": "OK", "manifest": manifest}


func validate(manifest: Dictionary, expected_context: Dictionary) -> Dictionary:
	if not manifest.get("schema_version") is int or manifest["schema_version"] != SCHEMA_VERSION:
		return _failure("UNSUPPORTED_SCHEMA")
	if JSON.stringify(manifest).length() > MAX_BYTES:
		return _failure("BUDGET_EXCEEDED")
	if not manifest.get("context") is Dictionary or not _valid_context(manifest["context"]):
		return _failure("INVALID_CONTEXT")
	var context: Dictionary = manifest["context"]
	for identity: String in ["source", "fixture", "profile", "tools", "scenario", "seed", "route"]:
		if not expected_context.has(identity) or expected_context[identity] != context[identity]:
			return _failure("IDENTITY_MISMATCH")
	if not manifest.get("gates") is Array or manifest["gates"].size() > MAX_GATES:
		return _failure("INVALID_GATES")
	if not manifest.get("artifacts") is Array or manifest["artifacts"].size() > MAX_ARTIFACTS:
		return _failure("INVALID_ARTIFACTS")
	if not _public_value(manifest, 0):
		return _failure("PRIVATE_DATA")
	var artifacts_by_channel: Dictionary = {}
	var artifact_ids: Dictionary = {}
	for artifact: Variant in manifest["artifacts"]:
		if not artifact is Dictionary or not _valid_artifact(artifact) or artifact_ids.has(artifact["id"]):
			return _failure("INVALID_ARTIFACTS")
		artifact_ids[artifact["id"]] = true
		artifacts_by_channel[artifact["channel"]] = true
	var ids: Dictionary = {}
	for gate: Variant in manifest["gates"]:
		if not gate is Dictionary or not gate.get("id") is String or gate["id"].is_empty() or gate["id"].length() > 128:
			return _failure("INVALID_GATES")
		if ids.has(gate["id"]) or gate.get("channel") not in CHANNELS or gate.get("status") not in STATUSES:
			return _failure("INVALID_GATES")
		ids[gate["id"]] = true
		if gate["status"] == "passed" and gate["channel"] in ["pixels", "audio", "provider", "export"] and not artifacts_by_channel.has(gate["channel"]):
			return _failure("MISSING_ARTIFACT")
	return {"ok": true, "code": "OK", "qualified_channels": _qualified_channels(manifest["gates"])}


func require_channels(manifest: Dictionary, expected_context: Dictionary, channels: Array[String]) -> Dictionary:
	var validation: Dictionary = validate(manifest, expected_context)
	if not validation["ok"]:
		return validation
	var qualified: Array[String] = validation["qualified_channels"]
	for channel: String in channels:
		if channel not in CHANNELS:
			return _failure("UNKNOWN_CHANNEL")
		if channel not in qualified:
			return {"ok": false, "code": "MISSING_GATE", "channel": channel}
	return validation


func _valid_context(context: Dictionary) -> bool:
	if not context.get("source") is Dictionary or not context.get("fixture") is Dictionary or not context.get("tools") is Dictionary:
		return false
	var source: Dictionary = context["source"]
	var fixture: Dictionary = context["fixture"]
	if not source.get("commit", "") is String or not source.get("tree_hash", "") is String or not source.get("dirty", false) is bool:
		return false
	if source.get("commit", "").is_empty() and source.get("tree_hash", "").is_empty():
		return false
	if source.get("dirty", false) and source.get("tree_hash", "").is_empty():
		return false
	if not fixture.get("id") is String or fixture["id"].is_empty() or not _sha256(fixture.get("hash")):
		return false
	if context["tools"].is_empty() or not context.get("seed") is int or context["seed"] < 0:
		return false
	for key: String in ["profile", "scenario", "route"]:
		if not context.get(key) is String or context[key].is_empty() or context[key].length() > 128:
			return false
	return true


func _valid_artifact(artifact: Dictionary) -> bool:
	if not artifact.get("id") is String or artifact["id"].is_empty() or artifact["id"].length() > 128:
		return false
	if artifact.get("channel") not in CHANNELS or not _sha256(artifact.get("sha256")):
		return false
	if not artifact.get("bytes") is int or artifact["bytes"] < 1:
		return false
	if not artifact.get("path") is String or not _relative_path(artifact["path"]):
		return false
	return artifact.get("producer") is String and not artifact["producer"].is_empty()


func _sha256(value: Variant) -> bool:
	if not value is String or value.length() != 64:
		return false
	for character: String in value:
		if character not in "0123456789abcdef":
			return false
	return true


func _relative_path(path: String) -> bool:
	if path.is_empty() or path.length() > 512 or path.is_absolute_path() or path.contains(":") or path.contains("\\"):
		return false
	for part: String in path.split("/"):
		if part in ["", ".", ".."]:
			return false
	return true


func _public_value(value: Variant, depth: int) -> bool:
	if depth > 8:
		return false
	if value is String:
		return value.length() <= 4096 and not value.is_absolute_path() and not value.contains(":\\") and not value.begins_with("file://")
	if value is bool or value == null:
		return true
	if value is int or value is float:
		return is_finite(float(value))
	if value is Dictionary:
		if value.size() > 128:
			return false
		for key: Variant in value:
			if not key is String or key.length() > 128:
				return false
			var lower: String = key.to_lower()
			for secret: String in ["token", "password", "secret", "authorization", "private_path", "endpoint"]:
				if lower.contains(secret):
					return false
			if not _public_value(value[key], depth + 1):
				return false
		return true
	if value is Array:
		if value.size() > 128:
			return false
		for item: Variant in value:
			if not _public_value(item, depth + 1):
				return false
		return true
	return false


func _qualified_channels(gates: Array) -> Array[String]:
	var statuses: Dictionary = {}
	for gate: Dictionary in gates:
		var channel: String = gate["channel"]
		if not statuses.has(channel):
			statuses[channel] = true
		statuses[channel] = statuses[channel] and gate["status"] == "passed"
	var qualified: Array[String] = []
	for channel: String in CHANNELS:
		if statuses.get(channel, false):
			qualified.append(channel)
	return qualified


func _failure(code: String) -> Dictionary:
	return {"ok": false, "code": code}
