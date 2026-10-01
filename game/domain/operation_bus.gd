extends RefCounted

signal receipt_emitted(receipt: Dictionary)
signal event_emitted(event: Dictionary)

const MAX_REQUESTS: int = 4096
const MAX_HISTORY: int = 256
const MAX_OPERATIONS: int = 512
const MAX_ARGUMENTS: int = 32
const SAFE_INTEGER: int = 9007199254740991

var _operations: Dictionary = {}
var _ledger: Dictionary = {}
var _receipts: Array[Dictionary] = []
var _events: Array[Dictionary] = []
var _revision: int = 0
var _tick: int = 0
var _epoch: int = 0
var _sequence: int = 0
var _dispatching: bool = false


func register_operation(descriptor: Dictionary, handler: Callable) -> Error:
	if not handler.is_valid() or not _valid_descriptor(descriptor):
		return ERR_INVALID_PARAMETER
	var name: String = descriptor["name"]
	if _operations.has(name):
		return ERR_ALREADY_EXISTS
	if _operations.size() >= MAX_OPERATIONS:
		return ERR_OUT_OF_MEMORY
	_operations[name] = {"descriptor": descriptor.duplicate(true), "handler": handler}
	return OK


func unregister_scope(scope: String) -> void:
	for name: String in _operations.keys():
		var entry: Dictionary = _operations[name]
		var descriptor: Dictionary = entry["descriptor"]
		if descriptor["scope"] == scope:
			_operations.erase(name)


func describe() -> Array[Dictionary]:
	var descriptions: Array[Dictionary] = []
	var names: Array = _operations.keys()
	names.sort()
	for name: String in names:
		var entry: Dictionary = _operations[name]
		descriptions.append(entry["descriptor"].duplicate(true))
	return descriptions


func submit(request: Dictionary) -> Dictionary:
	var request_id: String = request.get("request_id", "") if request.get("request_id", "") is String else ""
	var operation: String = request.get("operation", "") if request.get("operation", "") is String else ""
	if _dispatching:
		return _publish(_receipt(false, "REENTRANT_REQUEST", request_id, operation))
	if not _valid_request(request):
		return _publish(_receipt(false, "INVALID_REQUEST", request_id.left(128), operation.left(128)))
	var payload: String = _canonical(request)
	if _ledger.has(request_id):
		var prior: Dictionary = _ledger[request_id]
		if prior["payload"] != payload:
			return _publish(_receipt(false, "REQUEST_ID_REUSED", request_id, operation))
		return prior["receipt"].duplicate(true)
	if _ledger.size() >= MAX_REQUESTS:
		return _publish(_receipt(false, "BUDGET_EXCEEDED", request_id, operation))
	var code: String = ""
	if request.has("epoch") and request["epoch"] != _epoch:
		code = "STALE_EPOCH"
	elif not _operations.has(operation):
		code = "UNKNOWN_OPERATION"
	elif request.has("expected_revision") and request["expected_revision"] != _revision:
		code = "REVISION_CONFLICT"
	if not code.is_empty():
		return _remember(request_id, payload, _receipt(false, code, request_id, operation))
	var entry: Dictionary = _operations[operation]
	var descriptor: Dictionary = entry["descriptor"]
	var arguments: Dictionary = request["arguments"]
	if not _valid_arguments(arguments, descriptor):
		return _remember(request_id, payload, _receipt(false, "INVALID_ARGUMENT", request_id, operation))
	var handler: Callable = entry["handler"]
	if not handler.is_valid():
		return _remember(request_id, payload, _receipt(false, "OPERATION_UNAVAILABLE", request_id, operation))
	_dispatching = true
	var outcome: Variant = handler.call(arguments.duplicate(true))
	_dispatching = false
	if not outcome is Dictionary or not outcome.get("ok") is bool or not outcome.get("code") is String:
		return _remember(request_id, payload, _receipt(false, "INVALID_HANDLER_RESULT", request_id, operation))
	var succeeded: bool = outcome["ok"]
	if succeeded and descriptor["mutates"]:
		_revision += 1
	var result: Dictionary = outcome.duplicate(true)
	result.erase("ok")
	result.erase("code")
	if outcome.get("result") is Dictionary:
		result = outcome["result"].duplicate(true)
	var receipt: Dictionary = _receipt(succeeded, outcome["code"], request_id, operation, result)
	var applied_event: Dictionary = {}
	if succeeded and descriptor["mutates"]:
		_sequence += 1
		var event: Dictionary = {"sequence": _sequence, "tick": _tick, "revision": _revision, "epoch": _epoch, "operation": operation, "request_id": request_id, "arguments": arguments.duplicate(true)}
		applied_event = event
		_events.append(event)
		if _events.size() > MAX_HISTORY:
			_events.pop_front()
	# Seal retry identity before notifying observers that may submit another request.
	var published: Dictionary = _remember(request_id, payload, receipt)
	if not applied_event.is_empty():
		event_emitted.emit(applied_event.duplicate(true))
	return published


func advance_tick(tick: int) -> void:
	if tick < _tick:
		push_error("OperationBus cannot move its simulation tick backwards")
		return
	_tick = tick


func reset_epoch() -> void:
	_epoch += 1
	_ledger.clear()
	_receipts.clear()
	_events.clear()
	# Revisions, simulation ticks and event cursors remain monotonic across resets.


func observation() -> Dictionary:
	return {"revision": _revision, "tick": _tick, "epoch": _epoch, "sequence": _sequence, "ledger_count": _ledger.size(), "ledger_limit": MAX_REQUESTS, "receipts": _receipts.duplicate(true), "events": _events.duplicate(true)}


func events_since(cursor: int) -> Dictionary:
	if cursor < 0 or cursor > _sequence:
		return {"ok": false, "code": "INVALID_CURSOR", "cursor": _sequence, "events": []}
	var first: int = int(_events[0]["sequence"]) if not _events.is_empty() else _sequence + 1
	if cursor < first - 1:
		return {"ok": false, "code": "CURSOR_EXPIRED", "cursor": _sequence, "events": []}
	var selected: Array[Dictionary] = []
	for event: Dictionary in _events:
		if event["sequence"] > cursor:
			selected.append(event.duplicate(true))
	return {"ok": true, "code": "OK", "cursor": _sequence, "events": selected}


func _receipt(ok: bool, code: String, request_id: String, operation: String, result: Dictionary = {}) -> Dictionary:
	return {"ok": ok, "code": code, "request_id": request_id, "operation": operation, "revision": _revision, "tick": _tick, "epoch": _epoch, "result": result}


func _publish(receipt: Dictionary) -> Dictionary:
	_receipts.append(receipt.duplicate(true))
	if _receipts.size() > MAX_HISTORY:
		_receipts.pop_front()
	receipt_emitted.emit(receipt.duplicate(true))
	return receipt.duplicate(true)


func _remember(request_id: String, payload: String, receipt: Dictionary) -> Dictionary:
	_ledger[request_id] = {"payload": payload, "receipt": receipt.duplicate(true)}
	return _publish(receipt)


func _valid_request(request: Dictionary) -> bool:
	for key: Variant in request:
		if key not in ["operation", "arguments", "request_id", "expected_revision", "epoch"]:
			return false
	if not _identifier(request.get("operation")) or not _identifier(request.get("request_id")):
		return false
	if not request.get("arguments") is Dictionary or request["arguments"].size() > MAX_ARGUMENTS:
		return false
	for key: String in ["expected_revision", "epoch"]:
		if request.has(key) and (not _integer(request[key]) or request[key] < 0):
			return false
	return _bounded_value(request["arguments"], 0)


func _valid_descriptor(descriptor: Dictionary) -> bool:
	if not _identifier(descriptor.get("name")) or not _identifier(descriptor.get("scope")):
		return false
	if not descriptor.get("arguments") is Dictionary or not descriptor.get("required") is Array or not descriptor.get("mutates") is bool:
		return false
	var rules: Dictionary = descriptor["arguments"]
	if rules.size() > MAX_ARGUMENTS or descriptor["required"].size() > rules.size():
		return false
	var seen: Dictionary = {}
	for key: Variant in descriptor["required"]:
		if not key is String or not rules.has(key) or seen.has(key):
			return false
		seen[key] = true
	for key: Variant in rules:
		if not _identifier(key) or not rules[key] is Dictionary:
			return false
		var rule: Dictionary = rules[key]
		if rule.get("type") not in ["string", "number", "integer", "boolean", "vector3", "enum"]:
			return false
		if (rule.has("min") or rule.has("max")) and rule["type"] not in ["number", "integer", "vector3"]:
			return false
		if rule.has("max_length") and rule["type"] != "string":
			return false
		if rule.has("values") and rule["type"] != "enum":
			return false
		for bound: String in ["min", "max"]:
			if rule.has(bound) and not _finite_number(rule[bound]):
				return false
		if rule.has("min") and rule.has("max") and rule["min"] > rule["max"]:
			return false
		if rule.has("max_length") and (not rule["max_length"] is int or rule["max_length"] < 1 or rule["max_length"] > 4096):
			return false
		if rule["type"] == "enum":
			if not rule.get("values") is Array or rule["values"].is_empty() or rule["values"].size() > 128:
				return false
			for value: Variant in rule["values"]:
				if not (value is String or value is bool or _finite_number(value)):
					return false
	return true


func _valid_arguments(arguments: Dictionary, descriptor: Dictionary) -> bool:
	var rules: Dictionary = descriptor["arguments"]
	for key: Variant in arguments:
		if not key is String or not rules.has(key) or not _valid_argument(arguments[key], rules[key]):
			return false
	for key: String in descriptor["required"]:
		if not arguments.has(key):
			return false
	return true


func _valid_argument(value: Variant, rule: Dictionary) -> bool:
	match rule["type"]:
		"string":
			return value is String and value.length() <= int(rule.get("max_length", 1024))
		"boolean":
			return value is bool
		"number":
			return _number_in_bounds(value, rule)
		"integer":
			return _number_in_bounds(value, rule) and _integer(value)
		"enum":
			return value in rule["values"]
		"vector3":
			if value is Vector3:
				return _number_in_bounds(value.x, rule) and _number_in_bounds(value.y, rule) and _number_in_bounds(value.z, rule)
			if value is Dictionary and value.size() == 3 and value.has_all(["x", "y", "z"]):
				return _number_in_bounds(value["x"], rule) and _number_in_bounds(value["y"], rule) and _number_in_bounds(value["z"], rule)
	return false


func _number_in_bounds(value: Variant, rule: Dictionary) -> bool:
	return _finite_number(value) and float(value) >= float(rule.get("min", -SAFE_INTEGER)) and float(value) <= float(rule.get("max", SAFE_INTEGER))


func _finite_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))


func _integer(value: Variant) -> bool:
	return _finite_number(value) and abs(float(value)) <= SAFE_INTEGER and floor(float(value)) == float(value)


func _identifier(value: Variant) -> bool:
	return value is String and not value.is_empty() and value.length() <= 128


func _bounded_value(value: Variant, depth: int) -> bool:
	if depth > 4:
		return false
	if value is String:
		return value.length() <= 4096
	if value is Dictionary:
		if value.size() > MAX_ARGUMENTS:
			return false
		for key: Variant in value:
			if not _identifier(key) or not _bounded_value(value[key], depth + 1):
				return false
		return true
	if value is Vector3:
		return value.is_finite()
	return value is bool or _finite_number(value)


func _canonical(value: Variant) -> String:
	if value is float and _integer(value):
		return JSON.stringify(int(value))
	if value is Dictionary:
		var keys: Array = value.keys()
		keys.sort()
		var parts: PackedStringArray = []
		for key: String in keys:
			parts.append(JSON.stringify(key) + ":" + _canonical(value[key]))
		return "{" + ",".join(parts) + "}"
	if value is Vector3:
		return "vector3:" + JSON.stringify([value.x, value.y, value.z])
	return JSON.stringify(value)
