extends SceneTree
const Module = preload("res://labs/modules/visual_labs.gd")
const IDS: Array[String] = ["LAB-008", "LAB-009", "LAB-011", "LAB-016", "LAB-017", "LAB-019", "LAB-023", "LAB-055", "LAB-060", "LAB-061", "LAB-066", "LAB-068"]
var failures: Array[String] = []
var checks: int = 0
var unavailable: Array[String] = []

func _initialize() -> void:
	if "--inspect-api" in OS.get_cmdline_user_args():
		for method: Dictionary in ClassDB.class_get_method_list("AnimationNodeBlendSpace1D"):
			if method.name == "add_blend_point": print(JSON.stringify(method))
		quit()
	elif "--compile-only" in OS.get_cmdline_user_args():
		print("VISUAL_SOURCE_GATE PASS")
		quit()
	else: call_deferred("_run")

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
		_check(module.reset().get("ok", false), id + " reset")
		_check(module.observe().get("revision") == 0, id + " baseline revision")
		await _mechanism_checks(module, id)
		module.teardown()
		panel.free()
		module.free()
		await physics_frame
	for failure: String in failures: push_error(failure)
	print("VISUAL_LABS_GATE %s checks=%s failures=%s" % ["PASS" if failures.is_empty() else "FAIL", checks, failures.size()])
	if not unavailable.is_empty(): print("UNAVAILABLE_RENDERER_READBACK " + JSON.stringify(unavailable))
	quit(0 if failures.is_empty() else 1)

func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition: failures.append(label)

func _mechanism_checks(module: Node3D, id: String) -> void:
	await physics_frame
	match id:
		"LAB-008":
			module.apply_operation("animation.speed", {"blend": 1.0})
			module.apply_operation("animation.advance", {"seconds": 0.25})
			_check(module.sample.position.y > 1.22, "AnimationTree changes actual courier pose")
			module.apply_operation("animation.clip", {"clip": "salute"})
			module.apply_operation("animation.advance", {"seconds": 0.4})
			_check(absf(module.sample.rotation.z) > 0.4, "AnimationPlayer gesture drives actual rotation track")
		"LAB-011":
			module.ray.force_raycast_update()
			_check(module.ray.is_colliding(), "Camera rig ray hits courtyard collision")
			_check(module.arm.get_hit_length() < module.arm.spring_length, "SpringArm shortens against real occlusion")
		"LAB-016":
			var arrays: Array = module.terrain_mesh.mesh.surface_get_arrays(0)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			var winding: Vector3 = (vertices[indices[1]] - vertices[indices[0]]).cross(vertices[indices[2]] - vertices[indices[0]])
			_check(winding.y < 0, "Terrain top faces use Godot clockwise winding")
			var initial: String = module.observe().height_hash
			module.apply_operation("terrain.generate", {"seed": 77, "amplitude": 1.5})
			var generated: String = module.observe().height_hash
			module.apply_operation("terrain.generate", {"seed": 77, "amplitude": 1.5})
			_check(generated == module.observe().height_hash and generated != initial, "Terrain seeded samples repeat exactly and vary with recipe")
			await physics_frame
			var query := PhysicsRayQueryParameters3D.create(Vector3(0, 8, 0), Vector3(0, -2, 0), 1)
			var hit: Dictionary = module.get_world_3d().direct_space_state.intersect_ray(query)
			_check(hit.get("collider") == module.terrain_body, "HeightMapShape3D receives actual ray hit")
			if hit.has("position"): _check(absf(hit.position.y - float(module.terrain_samples[40])) < 0.02, "Terrain collision follows center sample within 2cm")
		"LAB-017":
			module.apply_operation("crowd.populate", {"count": 72, "seed": 77})
			var first: String = module.observe().transform_hash
			module.apply_operation("crowd.populate", {"count": 72, "seed": 77})
			_check(first == module.observe().transform_hash, "MultiMesh seeded transforms match on recreation")
			module.apply_operation("crowd.populate", {"count": 72, "seed": 78})
			_check(first != module.observe().transform_hash, "Changed seed changes authored MultiMesh transforms")
			module.apply_operation("crowd.tint", {"palette": "coral"})
			if DisplayServer.get_name() == "headless": unavailable.append("MultiMesh color GPU readback")
			else:
				var actual: Color = module.crowd.multimesh.get_instance_color(17)
				_check(_color_near(actual, module.CORAL), "Tint reaches actual MultiMesh instance color " + str(actual))
				_check(module.crowd.multimesh.get_instance_transform(17).is_equal_approx(module.crowd_transforms[17]), "Authored transform reaches actual MultiMesh renderer buffer")
		"LAB-023":
			module.apply_operation("garden.generate", {"seed": 77, "density": 0.4})
			var first: String = module.observe().topology_hash
			module.apply_operation("garden.generate", {"seed": 77, "density": 0.4})
			_check(first == module.observe().topology_hash, "Garden seeded topology repeats")
			module.apply_operation("garden.variant", {"variant": "sealed"})
			_check(first == module.observe().topology_hash, "Rejected garden leaves exact prior topology intact")
		"LAB-060":
			var initial: String = module.observe().atlas_hash
			var neighbor: Color = module.image.get_pixel(15, 16)
			module.apply_operation("atlas.paint", {"x": 16, "y": 16, "color": "coral"})
			_check(module.image.get_pixel(15, 16) == neighbor, "Atlas edit leaves neighbor pixel unchanged")
			if DisplayServer.get_name() == "headless": unavailable.append("ImageTexture updated GPU readback")
			else:
				var actual: Color = module.texture.get_image().get_pixel(16, 16)
				_check(_color_near(actual, module.CORAL), "ImageTexture receives actual edited pixel " + str(actual))
			module.apply_operation("atlas.undo", {})
			_check(initial == module.observe().atlas_hash, "Atlas undo restores original exact byte hash")
		"LAB-061":
			module.apply_operation("vertex.paint", {"vertex": 4, "color": "coral"})
			var tool := MeshDataTool.new()
			tool.create_from_surface(module.sample.mesh, 0)
			var found: bool = false
			for index: int in range(tool.get_vertex_count()):
				if tool.get_vertex(index).is_equal_approx(Vector3(0, 2.2, 0)) and tool.get_vertex_color(index).is_equal_approx(module.CORAL): found = true
			_check(found, "SurfaceTool color survives actual MeshDataTool attribute readback")

func _color_near(left: Color, right: Color) -> bool:
	return absf(left.r - right.r) <= 0.005 and absf(left.g - right.g) <= 0.005 and absf(left.b - right.b) <= 0.005 and absf(left.a - right.a) <= 0.005
