extends SceneTree

const DataLabsScript: GDScript = preload("res://labs/modules/data_labs.gd")
const LAB_IDS: Array[String] = ["LAB-025", "LAB-028", "LAB-036", "LAB-089", "LAB-091", "LAB-092"]

var _checks: int = 0
var _failures: Array[String] = []


func _initialize() -> void:
	_run()


func _run() -> void:
	for lab_index: int in range(LAB_IDS.size()):
		var lab_id: String = LAB_IDS[lab_index]
		var module: Node3D = DataLabsScript.new()
		module.lab_id = lab_id
		root.add_child(module)
		module.setup({"host": self, "player": null, "camera": null, "automation": true,
			"namespace": "gate-data-%d" % lab_index})
		_check(bool(module.describe().get("ready", false)), lab_id + " ready")
		_check(str(module.describe().get("source_fingerprint", "")).length() == 64,
			lab_id + " source fingerprint present")
		_check(bool(module.describe().get("source_fingerprint_verified", false)),
			lab_id + " source fingerprint verified in source project")
		var steps: Array[Dictionary] = module.scenario()
		var positives: int = 0
		var negatives: int = 0
		_check(steps.size() >= 5, lab_id + " has substantive scenario")
		for step_index: int in range(steps.size()):
			var step: Dictionary = steps[step_index]
			var expected_ok: bool = bool(step.get("expect_ok", true))
			positives += 1 if expected_ok else 0
			negatives += 0 if expected_ok else 1
			var result: Dictionary = {}
			if step.has("poll_until_code"):
				var timeout_msec: int = int(step.get("timeout_msec", 0))
				_check(timeout_msec > 0 and timeout_msec <= 10000, lab_id + " polling deadline bound")
				var started_msec: int = Time.get_ticks_msec()
				while true:
					result = module.apply_operation(str(step["operation"]), step["arguments"])
					if not bool(result.get("ok", false)) or str(result.get("code", "")) == str(step["poll_until_code"]):
						break
					if Time.get_ticks_msec() - started_msec >= timeout_msec:
						break
					await physics_frame
			else:
				result = module.apply_operation(str(step["operation"]), step["arguments"])
			_check(bool(result.get("ok", false)) == expected_ok,
				lab_id + " step " + str(step_index) + " success expectation " + JSON.stringify(result))
			if step.has("expect_code"):
				_check(str(result.get("code", "")) == str(step["expect_code"]),
					lab_id + " step " + str(step_index) + " code " + JSON.stringify(result))
			var observed: Dictionary = module.observe()
			_check(_contains_expected(observed, step.get("assert", {})),
				lab_id + " step " + str(step_index) + " observation " + JSON.stringify(observed))
			var wait_ticks: int = int(step.get("wait_ticks", 0))
			_check(wait_ticks >= 0 and wait_ticks <= 300, lab_id + " wait bound")
			for wait_index: int in range(wait_ticks):
				await process_frame
		_check(positives >= 3 and negatives >= 2,
			lab_id + " positive and negative coverage positives=" + str(positives) + " negatives=" + str(negatives))
		var controls: Control = Control.new()
		root.add_child(controls)
		module.create_controls(controls)
		_check(controls.get_child_count() >= 3, lab_id + " controls created")
		module.teardown()
		controls.queue_free()
		module.queue_free()
		await process_frame
	if _failures.is_empty():
		print("DATA_LABS_GATE_PASS checks=%d labs=%d" % [_checks, LAB_IDS.size()])
		quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("DATA_LABS_GATE_FAIL checks=%d failures=%d" % [_checks, _failures.size()])
		quit(1)


func _contains_expected(actual: Dictionary, expected: Dictionary) -> bool:
	for key: Variant in expected.keys():
		if not actual.has(key):
			return false
		var wanted: Variant = expected[key]
		var received: Variant = actual[key]
		if wanted is Dictionary:
			if not received is Dictionary or not _contains_expected(received, wanted):
				return false
		elif wanted is Array:
			if received != wanted:
				return false
		elif received != wanted:
			return false
	return true


func _check(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(label)
