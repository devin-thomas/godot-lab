extends SceneTree

const Bus = preload("res://domain/operation_bus.gd")
const Record = preload("res://domain/simulation_record.gd")
const Evidence = preload("res://domain/evidence_manifest.gd")

var _checks: Array[Dictionary] = []
var _value: int = 0
var _calls: int = 0


func _initialize() -> void:
	_test_bus()
	_test_record()
	_test_evidence()
	var passed: bool = true
	for check: Dictionary in _checks:
		passed = passed and check["passed"]
	var report: Dictionary = {"ok": passed, "engine": Engine.get_version_info()["string"], "route": "headless-domain", "checks": _checks, "limits": ["Synchronous dispatch only; no authenticated transport claim", "Record validation does not qualify portable deterministic physics", "Manifest validates identities and declarations; artifact bytes require external inspection"]}
	print("DOMAIN_GATE " + JSON.stringify(report))
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--report="):
			var file: FileAccess = FileAccess.open(argument.trim_prefix("--report="), FileAccess.WRITE)
			if file == null:
				push_error("Cannot open domain gate report")
				passed = false
			else:
				file.store_string(JSON.stringify(report, "\t") + "\n")
	quit(0 if passed else 1)


func _test_bus() -> void:
	var bus: RefCounted = Bus.new()
	var descriptor: Dictionary = {"name": "counter.add", "scope": "counter", "arguments": {"amount": {"type": "integer", "min": 1, "max": 5}}, "required": ["amount"], "mutates": true}
	_expect("register valid typed operation", bus.register_operation(descriptor, _add) == OK)
	_expect("duplicate registration rejected", bus.register_operation(descriptor, _add) == ERR_ALREADY_EXISTS)
	var meaningless: Dictionary = descriptor.duplicate(true)
	meaningless["name"] = "counter.bad_schema"
	meaningless["arguments"]["amount"] = {"type": "string", "min": 1}
	_expect("meaningless string numeric bound rejected at registration", bus.register_operation(meaningless, _add) == ERR_INVALID_PARAMETER)
	bus.advance_tick(12)
	var request: Dictionary = {"operation": "counter.add", "arguments": {"amount": 3}, "request_id": "player-1", "expected_revision": 0, "epoch": 0}
	var receipt: Dictionary = bus.submit(request)
	_expect("real handler applied once at declared tick", receipt["ok"] and _value == 3 and _calls == 1 and receipt["revision"] == 1 and receipt["tick"] == 12)
	_expect("identical retry returns original receipt without repeating effect", bus.submit(request) == receipt and _value == 3 and _calls == 1)
	var wire_request: Dictionary = JSON.parse_string(JSON.stringify(request))
	_expect("identical JSON retry shares UI integer request identity", bus.submit(wire_request) == receipt and _value == 3 and _calls == 1)
	var changed: Dictionary = request.duplicate(true)
	changed["arguments"]["amount"] = 4
	_expect("conflicting request ID rejected before effect", bus.submit(changed)["code"] == "REQUEST_ID_REUSED" and _value == 3)
	_expect("stale revision rejected before effect", bus.submit({"operation": "counter.add", "arguments": {"amount": 1}, "request_id": "stale", "expected_revision": 0})["code"] == "REVISION_CONFLICT" and _value == 3)
	for arguments: Dictionary in [{"amount": 9}, {"amount": -1}, {"amount": "3"}, {"amount": 2.5}, {"amount": 1, "extra": true}, {}]:
		var failure: Dictionary = bus.submit({"operation": "counter.add", "arguments": arguments, "request_id": "bad-" + str(_checks.size())})
		_expect("invalid argument has no effect: " + str(arguments), not failure["ok"] and _value == 3)
	_expect("nonfinite rejected before effect", not bus.submit({"operation": "counter.add", "arguments": {"amount": INF}, "request_id": "infinity"})["ok"] and _value == 3)
	_expect("nested nonstring argument key rejected without typed iteration error", bus.submit({"operation": "counter.add", "arguments": {"amount": {2: 3}}, "request_id": "nested-key"})["code"] == "INVALID_REQUEST" and _value == 3)
	_expect("unknown operation rejected", bus.submit({"operation": "counter.missing", "arguments": {}, "request_id": "unknown"})["code"] == "UNKNOWN_OPERATION")
	_expect("unknown executable request field rejected", bus.submit({"operation": "counter.add", "arguments": {"amount": 1}, "request_id": "unknown-field", "script": "anything"})["code"] == "INVALID_REQUEST")
	var read_descriptor: Dictionary = {"name": "counter.get", "scope": "counter", "arguments": {}, "required": [], "mutates": false}
	bus.register_operation(read_descriptor, _read)
	var prior: Dictionary = bus.observation()
	var snapshot: Dictionary = bus.submit({"operation": "counter.get", "arguments": {}, "request_id": "query"})
	_expect("query preserves revision sequence and real state", snapshot["result"]["value"] == 3 and snapshot["revision"] == prior["revision"] and bus.observation()["sequence"] == prior["sequence"])
	var names: Array[Dictionary] = bus.describe()
	names[0]["name"] = "tampered"
	_expect("descriptions are defensive copies", bus.describe()[0]["name"] == "counter.add")
	bus.reset_epoch()
	_expect("old epoch rejected after reset", bus.submit({"operation": "counter.add", "arguments": {"amount": 1}, "request_id": "old-epoch", "epoch": 0})["code"] == "STALE_EPOCH" and _value == 3)
	_expect("old event cursor reports expired history", bus.events_since(0)["code"] == "CURSOR_EXPIRED")
	bus.unregister_scope("counter")
	_expect("scope teardown removes its operations", bus.describe().is_empty())
	var disabled: RefCounted = Bus.new()
	disabled.register_operation(descriptor, _disabled)
	_expect("disabled mechanism negative control fails without state change", not disabled.submit({"operation": "counter.add", "arguments": {"amount": 1}, "request_id": "disabled"})["ok"] and _value == 3)
	var bounded: RefCounted = Bus.new()
	bounded.register_operation(read_descriptor, _read)
	for index: int in range(Bus.MAX_REQUESTS):
		bounded.submit({"operation": "counter.get", "arguments": {}, "request_id": "capacity-" + str(index)})
	_expect("ledger saturation refuses new IDs and preserves earliest retry", bounded.submit({"operation": "counter.get", "arguments": {}, "request_id": "overflow"})["code"] == "BUDGET_EXCEEDED" and bounded.submit({"operation": "counter.get", "arguments": {}, "request_id": "capacity-0"})["ok"])
	_expect("receipt history bounded separately from ledger", bounded.observation()["receipts"].size() == Bus.MAX_HISTORY and bounded.observation()["ledger_count"] == Bus.MAX_REQUESTS)


func _test_record() -> void:
	var recorder: RefCounted = Record.new()
	var context: Dictionary = {"source": {"commit": "test-source"}, "fixture": {"id": "counter", "hash": "f".repeat(64)}, "seed": 41, "tick_rate": 60, "profile": "CoreLocal", "allowed_operations": ["counter.add"], "tolerances": {"counter": 0}}
	_expect("fixed clock context configured", recorder.configure(context)["ok"])
	_expect("first command recorded", recorder.append_operation(2, 1, {"operation": "counter.add", "arguments": {"amount": 3}})["ok"])
	_expect("same tick command preserves explicit sequence", recorder.append_operation(2, 2, {"operation": "counter.add", "arguments": {"amount": 4}})["ok"])
	_expect("negative ticks refused", not recorder.append_operation(-1, 3, {"operation": "counter.add", "arguments": {"amount": 1}})["ok"])
	_expect("sequence conflicts refused", not recorder.append_operation(3, 2, {"operation": "counter.add", "arguments": {"amount": 1}})["ok"])
	_expect("unordered ticks refused", not recorder.append_operation(1, 3, {"operation": "counter.add", "arguments": {"amount": 1}})["ok"])
	_expect("unknown recorded operation refused", not recorder.append_operation(3, 3, {"operation": "unknown", "arguments": {}})["ok"])
	recorder.append_event(2, 1, {"name": "counter_changed"})
	recorder.checkpoint(2, 1, {"value": 7})
	recorder.finish(4)
	var record: Dictionary = recorder.export_record()
	var replay: RefCounted = Record.new()
	_expect("complete record imports with matching exact context", replay.load_record(record, context)["ok"])
	var wire_record: Dictionary = JSON.parse_string(JSON.stringify(record, "", true, true))
	_expect("serialized JSON record round trip accepted", replay.load_record(wire_record, context)["ok"])
	var commands: Array[Dictionary] = replay.operations_at_tick(2)
	var replay_value: int = 0
	for command: Dictionary in commands:
		replay_value += int(command["arguments"]["amount"])
	_expect("replayed ordered commands produce real semantic total", commands.size() == 2 and commands[0]["sequence"] < commands[1]["sequence"] and replay_value == 7)
	var tampered: Dictionary = record.duplicate(true)
	tampered["operations"][0]["arguments"]["amount"] = 5
	_expect("tampered content rejected preserving loaded history", replay.load_record(tampered)["code"] == "CONTENT_MISMATCH" and replay.operations_at_tick(2) == commands)
	var wrong: Dictionary = context.duplicate(true)
	wrong["fixture"]["hash"] = "e".repeat(64)
	_expect("wrong fixture identity refused", replay.load_record(record, wrong)["code"] == "CONTEXT_MISMATCH")
	tampered = record.duplicate(true)
	tampered["schema_version"] = 2
	_expect("future record version refused", replay.load_record(tampered)["code"] == "UNSUPPORTED_SCHEMA")
	tampered = record.duplicate(true)
	tampered["operations"][1]["sequence"] = 1
	_reseal(tampered)
	_expect("even rehashed conflicting sequence refused", replay.load_record(tampered)["code"] == "INVALID_ORDER")
	tampered = record.duplicate(true)
	tampered["operations"][0]["tick"] = -1
	_reseal(tampered)
	_expect("even rehashed negative tick refused", replay.load_record(tampered)["code"] == "INVALID_ORDER")
	_expect("record explicitly avoids deterministic physics claim", record["deterministic_physics"] == false)


func _test_evidence() -> void:
	var evidence: RefCounted = Evidence.new()
	var context: Dictionary = {"source": {"commit": "test-source", "dirty": false}, "fixture": {"id": "counter", "hash": "f".repeat(64)}, "profile": "CoreLocal", "tools": {"engine": Engine.get_version_info()["string"]}, "scenario": "counter-v1", "seed": 41, "route": "headless-domain"}
	var gates: Array[Dictionary] = [{"id": "counter-total", "channel": "logic", "status": "passed"}, {"id": "audio-deferred", "channel": "audio", "status": "pending"}]
	var built: Dictionary = evidence.build(context, gates)
	_expect("source bound logic manifest accepted", built["ok"])
	if not built["ok"]:
		return
	var manifest: Dictionary = built["manifest"]
	var logic_channels: Array[String] = ["logic"]
	var audio_channels: Array[String] = ["audio"]
	_expect("logic gate qualifies only its channel", evidence.require_channels(manifest, context, logic_channels)["ok"] and evidence.require_channels(manifest, context, audio_channels)["code"] == "MISSING_GATE")
	var stale: Dictionary = context.duplicate(true)
	stale["source"]["commit"] = "stale-source"
	_expect("another source cannot qualify current build", evidence.validate(manifest, stale)["code"] == "IDENTITY_MISMATCH")
	stale = context.duplicate(true)
	stale["fixture"]["hash"] = "e".repeat(64)
	_expect("another fixture cannot qualify current build", evidence.validate(manifest, stale)["code"] == "IDENTITY_MISMATCH")
	stale = context.duplicate(true)
	stale["profile"] = "RenderAdvanced"
	_expect("another renderer profile cannot qualify current build", evidence.validate(manifest, stale)["code"] == "IDENTITY_MISMATCH")
	var false_audio: Array[Dictionary] = [{"id": "invented-audio", "channel": "audio", "status": "passed"}]
	_expect("audio success requires its artifact declaration", evidence.build(context, false_audio)["code"] == "MISSING_ARTIFACT")
	var private_context: Dictionary = context.duplicate(true)
	private_context["token"] = "must-never-escape"
	_expect("credentials refused from publishable manifest", evidence.build(private_context, gates)["code"] == "PRIVATE_DATA")
	var bad_artifacts: Array[Dictionary] = [{"id": "audio", "channel": "audio", "path": "../outside.wav", "bytes": 5, "sha256": "a".repeat(64), "producer": "test"}]
	_expect("artifact traversal refused", evidence.build(context, gates, bad_artifacts)["code"] == "INVALID_ARTIFACTS")
	var artifacts: Array[Dictionary] = [{"id": "audio", "channel": "audio", "path": "audio/cue.wav", "bytes": 5, "sha256": "a".repeat(64), "producer": "test"}]
	_expect("audio artifact declaration allows separate audio qualification", evidence.build(context, false_audio, artifacts)["ok"])


func _add(arguments: Dictionary) -> Dictionary:
	_value += int(arguments["amount"])
	_calls += 1
	return {"ok": true, "code": "OK", "result": {"value": _value}}


func _read(_arguments: Dictionary) -> Dictionary:
	return {"ok": true, "code": "OK", "result": {"value": _value}}


func _disabled(_arguments: Dictionary) -> Dictionary:
	return {"ok": false, "code": "CAPABILITY_UNAVAILABLE"}


func _reseal(record: Dictionary) -> void:
	var content: Dictionary = record.duplicate(true)
	content.erase("content_hash")
	record["content_hash"] = JSON.stringify(content, "", true, true).sha256_text()


func _expect(name: String, passed: bool) -> void:
	_checks.append({"name": name, "passed": passed})
