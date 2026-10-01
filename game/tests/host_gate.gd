extends SceneTree

class RefusingReset extends Node3D:
	func reset() -> Dictionary:
		return {"ok": false, "code": "CANCEL_REQUIRED"}
	func observe() -> Dictionary:
		return {"revision": 0}
	func teardown() -> void:
		pass

var checks: Array[Dictionary] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var scene: PackedScene = load("res://main.tscn")
	var host: Node3D = scene.instantiate()
	root.add_child(host)
	await process_frame
	for index: int in range(40):
		var receipt: Dictionary = host.operation_bus.submit({"operation": "host.observe", "arguments": {}, "request_id": "observe-%d" % index})
		var state: Dictionary = receipt["result"]
		_check(receipt["ok"] and not state.has("last_receipt") and not state["operation_bus"].has("receipts") and JSON.stringify(receipt).length() < 20000, "bounded-observer-%d" % index)
	var mock: Node3D = RefusingReset.new()
	host.add_child(mock)
	host.active_module = mock
	var epoch: int = host.operation_bus.observation()["epoch"]
	var reset: Dictionary = host.operation_bus.submit({"operation": "host.reset", "arguments": {}, "request_id": "refused-reset"})
	_check(not reset["ok"] and reset["code"] == "CANCEL_REQUIRED" and host.operation_bus.observation()["epoch"] == epoch, "reset-failure-preserves-epoch")
	host.active_module = null
	mock.free()
	host.command("enter", "LAB-013")
	var confirm: Button = host.module_controls.find_child("Confirm", true, false)
	var before_ui: int = host.operation_bus.observation()["revision"]
	if confirm != null:
		confirm.pressed.emit()
	_check(confirm != null and host.active_module.observe().get("setting") == true, "real-Control-press-dispatches-module-operation")
	_check(host.operation_bus.observation()["revision"] == before_ui + 1, "Control-press-uses-shared-bus-receipt")
	var revision: int = host.operation_bus.observation()["revision"]
	host.command("reset")
	_check(host.operation_bus.observation()["revision"] == revision + 1, "UI-reset-advances-shared-revision")
	var stale: Dictionary = host.operation_bus.submit({"operation": "ui.set_setting", "arguments": {"enabled": true}, "expected_revision": revision, "request_id": "pre-UI-reset"})
	_check(not stale["ok"] and stale["code"] == "REVISION_CONFLICT", "UI-reset-rejects-old-revision")
	host.command.call_deferred("hub", "", false)
	var interrupted: Dictionary = await host.module_scenario("LAB-013")
	_check(not interrupted["passed"] and interrupted.get("code") == "SCENARIO_INTERRUPTED", "exiting-active-scenario-cancels-proof")
	_check(host.current == "hub" and host.active_module == null, "interrupted-scenario-leaves-usable-hub")
	host.free()
	await process_frame
	var passed: bool = true
	for check: Dictionary in checks:
		passed = passed and check["passed"]
	print("HOST_GATE %s checks=%d" % ["PASS" if passed else "FAIL", checks.size()])
	quit(0 if passed else 1)


func _check(passed: bool, name: String) -> void:
	checks.append({"name": name, "passed": passed})
	if not passed:
		push_error(name)
