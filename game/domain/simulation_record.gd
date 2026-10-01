extends RefCounted

const FORMAT: String = "godot-lab-operations-v1"
const VERSION: int = 1
const MAX_RECORDS: int = 4096
const MAX_BYTES: int = 1048576

var _context: Dictionary = {}
var _operations: Array[Dictionary] = []
var _events: Array[Dictionary] = []
var _checkpoints: Array[Dictionary] = []
var _last_tick: int = -1
var _last_sequence: int = -1
var _terminal_tick: int = 0


func configure(context: Dictionary) -> Dictionary:
	var code: String = _context_error(context)
	if not code.is_empty():
		return _answer(false, code)
	_context = context.duplicate(true)
	_context["tick_rate"] = context.get("tick_rate", 60)
	_context["profile"] = context.get("profile", "CoreLocal")
	_context["tolerances"] = context.get("tolerances", {"physics_position_meters": 0.01}).duplicate(true)
	_operations.clear()
	_events.clear()
	_checkpoints.clear()
	_last_tick = -1
	_last_sequence = -1
	_terminal_tick = 0
	return _answer(true, "OK")


func append_operation(tick: int, sequence: int, request: Dictionary) -> Dictionary:
	if _context.is_empty():
		return _answer(false, "NOT_CONFIGURED")
	if tick < 0 or sequence < 0:
		return _answer(false, "INVALID_ORDER")
	if tick < _last_tick or sequence <= _last_sequence:
		return _answer(false, "INVALID_ORDER")
	if _operations.size() >= MAX_RECORDS:
		return _answer(false, "BUDGET_EXCEEDED")
	if not _valid_operation(request, _context):
		return _answer(false, "INVALID_OPERATION")
	var entry: Dictionary = {"tick": tick, "sequence": sequence, "operation": request["operation"], "arguments": _wire_arguments(request["arguments"])}
	if request.has("request_id"):
		entry["request_id"] = request["request_id"]
	var candidate: Array[Dictionary] = _operations.duplicate(true)
	candidate.append(entry)
	if JSON.stringify(candidate).length() + _auxiliary_bytes() > MAX_BYTES:
		return _answer(false, "BUDGET_EXCEEDED")
	_operations.append(entry)
	_last_tick = tick
	_last_sequence = sequence
	_terminal_tick = maxi(_terminal_tick, tick)
	return _answer(true, "OK")


func append_event(tick: int, sequence: int, event: Dictionary) -> Dictionary:
	return _append_auxiliary(_events, tick, sequence, event)


func checkpoint(tick: int, sequence: int, observation: Dictionary) -> Dictionary:
	return _append_auxiliary(_checkpoints, tick, sequence, observation)


func finish(tick: int) -> Dictionary:
	if _context.is_empty() or tick < _terminal_tick:
		return _answer(false, "INVALID_ORDER")
	_terminal_tick = tick
	return _answer(true, "OK")


func export_record() -> Dictionary:
	if _context.is_empty():
		return {}
	var record: Dictionary = {"format": FORMAT, "schema_version": VERSION, "context": _context.duplicate(true), "operations": _operations.duplicate(true), "events": _events.duplicate(true), "checkpoints": _checkpoints.duplicate(true), "terminal_tick": _terminal_tick, "deterministic_physics": false}
	record["content_hash"] = _digest(record)
	return record


func load_record(record: Dictionary, expected_context: Dictionary = {}) -> Dictionary:
	if record.get("format") != FORMAT or not _integer(record.get("schema_version")) or record["schema_version"] != VERSION:
		return _answer(false, "UNSUPPORTED_SCHEMA")
	if JSON.stringify(record).length() > MAX_BYTES:
		return _answer(false, "BUDGET_EXCEEDED")
	if not record.get("content_hash") is String or record["content_hash"] != _digest(record):
		return _answer(false, "CONTENT_MISMATCH")
	if not record.get("context") is Dictionary:
		return _answer(false, "INVALID_CONTEXT")
	var context: Dictionary = record["context"].duplicate(true)
	if _integer(context.get("seed")):
		context["seed"] = int(context["seed"])
	if _integer(context.get("tick_rate")):
		context["tick_rate"] = int(context["tick_rate"])
	var code: String = _context_error(context)
	if not code.is_empty():
		return _answer(false, code)
	for key: Variant in expected_context:
		if not context.has(key) or _hash_value(context[key]) != _hash_value(expected_context[key]):
			return _answer(false, "CONTEXT_MISMATCH")
	if not _integer(record.get("terminal_tick")) or record["terminal_tick"] < 0 or record.get("deterministic_physics") != false:
		return _answer(false, "INVALID_RECORD")
	for field: String in ["operations", "events", "checkpoints"]:
		if not record.get(field) is Array or record[field].size() > MAX_RECORDS:
			return _answer(false, "BUDGET_EXCEEDED")
	var previous_tick: int = -1
	var previous_sequence: int = -1
	for entry: Variant in record["operations"]:
		if not entry is Dictionary or not _integer(entry.get("tick")) or not _integer(entry.get("sequence")):
			return _answer(false, "INVALID_ORDER")
		if entry["tick"] < 0 or entry["tick"] < previous_tick or entry["sequence"] < 0 or entry["sequence"] <= previous_sequence:
			return _answer(false, "INVALID_ORDER")
		if entry["tick"] > record["terminal_tick"] or not _valid_operation(entry, context):
			return _answer(false, "INVALID_OPERATION")
		previous_tick = int(entry["tick"])
		previous_sequence = int(entry["sequence"])
	for field: String in ["events", "checkpoints"]:
		if not _valid_auxiliary(record[field], int(record["terminal_tick"])):
			return _answer(false, "INVALID_RECORD")
	# Activate only after the entire imported history has passed validation.
	_context = context.duplicate(true)
	_operations.assign(record["operations"].duplicate(true))
	_events.assign(record["events"].duplicate(true))
	_checkpoints.assign(record["checkpoints"].duplicate(true))
	_last_tick = previous_tick
	_last_sequence = previous_sequence
	_terminal_tick = int(record["terminal_tick"])
	return _answer(true, "OK")


func operations_at_tick(tick: int) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for entry: Dictionary in _operations:
		if entry["tick"] == tick:
			entries.append(entry.duplicate(true))
	return entries


func _context_error(context: Dictionary) -> String:
	if not context.get("seed") is int or context["seed"] < 0:
		return "INVALID_SEED"
	for key: String in ["source", "fixture"]:
		if not context.get(key) is Dictionary or context[key].is_empty():
			return "INVALID_CONTEXT"
	var source: Dictionary = context["source"]
	var fixture: Dictionary = context["fixture"]
	if not source.get("commit", "") is String or not source.get("tree_hash", "") is String:
		return "INVALID_CONTEXT"
	if source.get("commit", "").is_empty() and source.get("tree_hash", "").is_empty():
		return "INVALID_CONTEXT"
	if not fixture.get("id") is String or fixture["id"].is_empty() or not fixture.get("hash") is String or fixture["hash"].length() != 64:
		return "INVALID_CONTEXT"
	var rate: Variant = context.get("tick_rate", 60)
	if not rate is int or rate < 1 or rate > 240:
		return "INVALID_TICK_RATE"
	if not context.get("profile", "CoreLocal") is String:
		return "INVALID_CONTEXT"
	if not context.get("tolerances", {}) is Dictionary:
		return "INVALID_TOLERANCE"
	var tolerances: Dictionary = context.get("tolerances", {})
	for key: Variant in tolerances:
		var value: Variant = tolerances[key]
		if not key is String or not (value is int or value is float) or not is_finite(float(value)) or value < 0:
			return "INVALID_TOLERANCE"
	if context.has("allowed_operations"):
		if not context["allowed_operations"] is Array or context["allowed_operations"].size() > 512:
			return "INVALID_CONTEXT"
		for operation: Variant in context["allowed_operations"]:
			if not operation is String or operation.is_empty() or operation.length() > 128:
				return "INVALID_CONTEXT"
	return "" if _portable(context, 0) else "INVALID_CONTEXT"


func _valid_operation(request: Dictionary, context: Dictionary) -> bool:
	if not request.get("operation") is String or request["operation"].is_empty() or request["operation"].length() > 128:
		return false
	if context.has("allowed_operations") and request["operation"] not in context["allowed_operations"]:
		return false
	if not request.get("arguments") is Dictionary or request["arguments"].size() > 32:
		return false
	if request.has("request_id") and (not request["request_id"] is String or request["request_id"].length() > 128):
		return false
	return _portable(request["arguments"], 0)


func _append_auxiliary(target: Array[Dictionary], tick: int, sequence: int, data: Dictionary) -> Dictionary:
	if _context.is_empty() or tick < 0 or sequence < 0 or not _portable(data, 0):
		return _answer(false, "INVALID_RECORD")
	if not target.is_empty() and (tick < target[-1]["tick"] or sequence <= target[-1]["sequence"]):
		return _answer(false, "INVALID_ORDER")
	if target.size() >= MAX_RECORDS:
		return _answer(false, "BUDGET_EXCEEDED")
	var entry: Dictionary = {"tick": tick, "sequence": sequence, "data": data.duplicate(true)}
	if JSON.stringify(_operations).length() + _auxiliary_bytes() + JSON.stringify(entry).length() > MAX_BYTES:
		return _answer(false, "BUDGET_EXCEEDED")
	target.append(entry)
	_terminal_tick = maxi(_terminal_tick, tick)
	return _answer(true, "OK")


func _valid_auxiliary(entries: Array, terminal_tick: int) -> bool:
	var last_tick: int = -1
	var last_sequence: int = -1
	for entry: Variant in entries:
		if not entry is Dictionary or not _integer(entry.get("tick")) or not _integer(entry.get("sequence")) or not entry.get("data") is Dictionary:
			return false
		if entry["tick"] < 0 or entry["tick"] < last_tick or entry["tick"] > terminal_tick or entry["sequence"] < 0 or entry["sequence"] <= last_sequence or not _portable(entry["data"], 0):
			return false
		last_tick = int(entry["tick"])
		last_sequence = int(entry["sequence"])
	return true


func _portable(value: Variant, depth: int) -> bool:
	if depth > 6:
		return false
	if value is String:
		return value.length() <= 4096
	if value is Vector3:
		return value.is_finite()
	if value is bool or value == null:
		return true
	if value is int or value is float:
		return is_finite(float(value))
	if value is Dictionary:
		if value.size() > 64:
			return false
		for key: Variant in value:
			if not key is String or key.length() > 128 or not _portable(value[key], depth + 1):
				return false
		return true
	if value is Array:
		if value.size() > 512:
			return false
		for item: Variant in value:
			if not _portable(item, depth + 1):
				return false
		return true
	return false


func _wire_arguments(arguments: Dictionary) -> Dictionary:
	var result: Dictionary = arguments.duplicate(true)
	for key: String in result:
		if result[key] is Vector3:
			var vector: Vector3 = result[key]
			result[key] = {"x": vector.x, "y": vector.y, "z": vector.z}
	return result


func _auxiliary_bytes() -> int:
	return JSON.stringify(_context).length() + JSON.stringify(_events).length() + JSON.stringify(_checkpoints).length() + 1024


func _digest(record: Dictionary) -> String:
	var content: Dictionary = record.duplicate(true)
	content.erase("content_hash")
	return JSON.stringify(_hash_value(content), "", true, true).sha256_text()


func _hash_value(value: Variant) -> Variant:
	# JSON parses integral numbers as floats; hash their semantic numeric value.
	if value is float and _integer(value):
		return int(value)
	if value is Dictionary:
		var result: Dictionary = {}
		for key: String in value:
			result[key] = _hash_value(value[key])
		return result
	if value is Array:
		var result: Array = []
		for item: Variant in value:
			result.append(_hash_value(item))
		return result
	return value


func _integer(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and abs(float(value)) <= 9007199254740991.0 and floor(float(value)) == float(value)


func _answer(ok: bool, code: String) -> Dictionary:
	return {"ok": ok, "code": code}
