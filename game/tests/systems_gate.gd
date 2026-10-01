extends SceneTree
const Module = preload("res://labs/modules/system_labs.gd")
const IDS: Array[String] = ["LAB-007", "LAB-012", "LAB-013", "LAB-014", "LAB-018", "LAB-037", "LAB-038", "LAB-039", "LAB-040", "LAB-041", "LAB-074", "LAB-075", "LAB-077", "LAB-078", "LAB-079", "LAB-080", "LAB-081"]
var failures: Array[String] = []
var checks: int = 0

func _initialize() -> void:
	if "--compile-only" in OS.get_cmdline_user_args():
		print("SYSTEMS_SOURCE_GATE PASS")
		quit()
	else:
		call_deferred("_run")

func _run() -> void:
	for id: String in IDS:
		var module := Module.new()
		module.lab_id = id
		root.add_child(module)
		module.setup({"automation": true})
		var panel := VBoxContainer.new()
		root.add_child(panel)
		module.create_controls(panel)
		await physics_frame
		await physics_frame
		for step: Dictionary in module.scenario():
			var receipt: Dictionary = module.apply_operation(String(step.operation), step.arguments)
			_check(bool(receipt.get("ok", false)) == bool(step.expect_ok), id + " " + String(step.operation) + " outcome " + JSON.stringify(receipt))
			if step.has("expect_code"): _check(receipt.get("code") == step.expect_code, id + " error identity " + JSON.stringify(receipt))
			var observation: Dictionary = module.observe()
			for key: String in step.get("assert", {}): _check(observation.get(key) == step["assert"][key], id + " " + key + " " + JSON.stringify(observation))
			await physics_frame
			if id == "LAB-007" and step.operation == "tiles.paint" and step.arguments.get("tile") == 1 and bool(step.expect_ok):
				var body: CharacterBody2D = module.domain.tile_body
				_check(body.test_move(body.global_transform, Vector2(32, 0)), "TileSet collision blocks physical body independently of domain guard")
				_check(module.domain.tile_map.get_cell_atlas_coords(Vector2i(2, 2)).x == 3, "Neighbor seam selects east-connected wall atlas")
		_check(module.reset().get("ok", false), id + " reset")
		_check(module.observe().get("revision") == 0, id + " baseline revision")
		module.teardown()
		panel.free()
		module.free()
		await physics_frame
	if not failures.is_empty():
		for failure: String in failures: push_error(failure)
	print("SYSTEMS_GATE %s checks=%s failures=%s" % ["PASS" if failures.is_empty() else "FAIL", checks, failures.size()])
	quit(0 if failures.is_empty() else 1)

func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition: failures.append(label)
