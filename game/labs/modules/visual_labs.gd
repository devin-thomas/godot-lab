extends "res://labs/lab_module.gd"
## Bounded original visual mechanisms; all controls and scenarios share dispatch.
var lab_id: String = "LAB-008"
var state: Dictionary = {}
var history: Array[Dictionary] = []
var proposal: Dictionary = {}
var fixture: Node3D
var sample: MeshInstance3D
var reference: MeshInstance3D
var animation_player: AnimationPlayer
var animation_tree: AnimationTree
var particles: CPUParticles3D
var preview: SubViewport
var preview_camera: Camera3D
var preview_texture: TextureRect
var arm: SpringArm3D
var ray: RayCast3D
var terrain_body: StaticBody3D
var terrain_mesh: MeshInstance3D
var terrain_samples: PackedFloat32Array = []
var crowd: MultiMeshInstance3D
var crowd_transforms: Array[Transform3D] = []
var shader_material: ShaderMaterial
var display_material: ShaderMaterial
var pathfinder: AStarGrid2D
var grid_blocks: Array[Vector2i] = []
var grid_visuals: Array[Node3D] = []
var image: Image
var texture: ImageTexture
var vertex_colors: Array[Color] = []
var vertex_positions: Array[Vector3] = [Vector3(-2, 0, -1), Vector3(2, 0, -1), Vector3(2, 0, 1), Vector3(-2, 0, 1), Vector3(0, 2.2, 0), Vector3(0, -0.8, 0)]
var readout: RichTextLabel
var phase: float = 0.0
const TITLES: Dictionary = {"LAB-008": "Animation Loom", "LAB-009": "Particle Weather", "LAB-011": "Camera Rig", "LAB-016": "Terrain Foundry", "LAB-017": "Crowd Balcony", "LAB-019": "Shader Bench", "LAB-023": "Procedural Garden", "LAB-055": "Grid Tactics", "LAB-060": "Atlas Author", "LAB-061": "Vertex Shade", "LAB-066": "Viewport Mirrors", "LAB-068": "Display Laboratory"}
const NOTES: Dictionary = {
	"LAB-008": "Blend idle/walk in a real AnimationTree. Play or interrupt the courier's brass salute. Sample actual animation time.",
	"LAB-009": "Tune an actual CPU particle emitter: rain or blossom, amount and lifetime. GPU comparison remains a separately gated route.",
	"LAB-011": "Inspect an owned camera preview. Perspective/orthographic projection and a spring arm respond to real courtyard collision.",
	"LAB-016": "Regenerate the original 9 x 9 island with a seed and amplitude. Mesh vertices and HeightMapShape3D use the same samples. Undo restores both.",
	"LAB-017": "Change a bounded MultiMesh lantern crowd. Actual instance transforms and per-instance color come from one seeded distribution.",
	"LAB-019": "Adjust a spatial shader's contrast uniform. The stone reference stays fixed. No arbitrary shader code is imported.",
	"LAB-023": "Grow an 8 x 8 garden from a seed. AStarGrid2D checks its protected path; a sealed proposal cannot replace the connected world.",
	"LAB-055": "Preview a turn path around blocked tiles, pay its exact movement cost, then undo. Wait invalidates a pending proposal.",
	"LAB-060": "Paint pixels inside the original padded motif. The ImageTexture updates on a tall banner with nearest sampling. Undo restores its bytes.",
	"LAB-061": "Paint the six semantic vertices of an angular sea-glass jewel. SurfaceTool writes colors; MeshDataTool inspects the resulting attributes.",
	"LAB-066": "View an original miniature harbor through a live ViewportTexture. Switch the camera and turn the fixture without changing the museum camera.",
	"LAB-068": "Compare native preview sizes and nearest sampling. Optional steady CRT lines affect only the image; essential controls remain full-resolution."}

func setup(context: Dictionary) -> void:
	super.setup(context)
	fixture = Node3D.new()
	fixture.name = "OriginalFixture"
	add_child(fixture)
	super.sign(String(TITLES.get(lab_id, lab_id)), Vector3(0, 4.5, -4), GOLD, 38)
	match lab_id:
		"LAB-008": _build_animation()
		"LAB-009": _build_particles()
		"LAB-011":
			sample = _courier(Vector3(0, 1, -2))
			box(Vector3(0, 2, 1.5), Vector3(6, 4, 0.4), INK, true)
			for x: float in [-4, 4]: box(Vector3(x, 1.5, -2), Vector3(1, 3, 5), STONE, true)
			_build_preview(true)
		"LAB-016":
			terrain_mesh = MeshInstance3D.new()
			fixture.add_child(terrain_mesh)
			terrain_body = StaticBody3D.new()
			fixture.add_child(terrain_body)
			var collision := CollisionShape3D.new()
			terrain_body.add_child(collision)
			_generate_terrain(17, 1.0)
		"LAB-017":
			crowd = MultiMeshInstance3D.new()
			fixture.add_child(crowd)
			_build_crowd(24, 17)
		"LAB-019":
			sample = _banner(Vector3(-2, 1.5, -2), MINT)
			reference = _banner(Vector3(2, 1.5, -2), STONE)
			shader_material = ShaderMaterial.new()
			shader_material.shader = preload("res://labs/visual/motif.gdshader")
			sample.material_override = shader_material
			_build_preview(false)
		"LAB-023", "LAB-055":
			pathfinder = AStarGrid2D.new()
			pathfinder.region = Rect2i(0, 0, 8, 8)
			pathfinder.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
			pathfinder.update()
			sample = _courier(Vector3(-3.5, 0.8, -3.5))
			if lab_id == "LAB-023": _generate_garden(17, 0.25, false)
			else:
				grid_blocks = [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(4, 4), Vector2i(5, 5)]
				_apply_grid()
		"LAB-060":
			sample = _banner(Vector3(0, 2, -2), Color.WHITE)
			_build_atlas()
		"LAB-061":
			sample = MeshInstance3D.new()
			sample.position = Vector3(0, 1.5, -2)
			fixture.add_child(sample)
			vertex_colors = [INK, STONE, STONE, INK, MINT, GOLD]
			_build_vertices()
		"LAB-066", "LAB-068":
			for x: float in [-3.5, 3.5]: box(Vector3(x, 1.6, -2), Vector3(0.5, 3.2, 0.7), GOLD)
			box(Vector3(0, 3.5, -2), Vector3(7.5, 0.5, 0.7), GOLD)
			_build_preview(false)
	reset()

func describe() -> Dictionary:
	return {"id": lab_id, "title": TITLES.get(lab_id, lab_id), "description": NOTES.get(lab_id, ""), "action": "OPERATE", "label": "Operate fixture", "ready": fixture != null, "limits": "Bounded original fixture implementation ahead of rendered/provider qualification. CPU particles only; no universal GPU speed claim. Seeded 9x9 terrain has no LOD/import adapter. Crowds use static lanterns. Shader sources are fixed originals. Viewport is an independent miniature, not recursive portals. Human comfort remains unqualified."}

func operations() -> Array[Dictionary]:
	match lab_id:
		"LAB-008": return [_op("animation.speed", {"blend": _number(0, 1)}), _op("animation.clip", {"clip": _string(32)}), _op("animation.advance", {"seconds": _number(0.01, 1)})]
		"LAB-009": return [_op("particles.configure", {"amount": _integer(8, 128), "lifetime": _number(0.5, 4), "mode": _enum(["rain", "blossom"])}), _op("particles.emit", {"enabled": _boolean()}), _op("particles.backend", {"backend": _enum(["cpu", "gpu"])})]
		"LAB-011": return [_op("camera.projection", {"mode": _enum(["perspective", "orthographic"])}), _op("camera.arm", {"meters": _number(2, 8)}), _op("camera.target", {"target": _string(24)})]
		"LAB-016": return [_op("terrain.generate", {"seed": _integer(0, 65535), "amplitude": _number(0, 2)}), _op("terrain.sculpt", {"x": _integer(0, 8), "z": _integer(0, 8), "height": _number(0, 3)}), _op("terrain.undo")]
		"LAB-017": return [_op("crowd.populate", {"count": _integer(1, 128), "seed": _integer(0, 65535)}), _op("crowd.tint", {"palette": _enum(["mint", "coral"])}), _op("crowd.clear")]
		"LAB-019": return [_op("shader.uniform", {"name": _string(24), "value": _number(0, 1)}), _op("shader.profile", {"profile": _string(24)})]
		"LAB-023": return [_op("garden.generate", {"seed": _integer(0, 65535), "density": _number(0, 0.6)}), _op("garden.variant", {"variant": _enum(["connected", "sealed"])}), _op("garden.walk")]
		"LAB-055": return [_op("tactics.preview", {"x": _integer(0, 7), "y": _integer(0, 7)}), _op("tactics.commit"), _op("tactics.wait"), _op("tactics.undo")]
		"LAB-060": return [_op("atlas.paint", {"x": _integer(0, 31), "y": _integer(0, 31), "color": _enum(["stone", "mint", "gold", "coral"])}), _op("atlas.undo"), _op("atlas.sampling", {"mode": _enum(["nearest", "linear"])})]
		"LAB-061": return [_op("vertex.paint", {"vertex": _integer(0, 5), "color": _enum(["ink", "stone", "mint", "gold", "coral"])}), _op("vertex.ramp", {"amount": _number(0, 1)}), _op("vertex.undo")]
		"LAB-066": return [_op("viewport.source", {"source": _string(24)}), _op("viewport.turn", {"degrees": _number(-180, 180)}), _op("viewport.recursion", {"depth": _integer(0, 8)})]
		"LAB-068": return [_op("display.resolution", {"width": _integer(64, 1024), "height": _integer(36, 576)}), _op("display.profile", {"profile": _enum(["clean", "crt"])})]
	return []

func apply_operation(operation: String, arguments: Dictionary) -> Dictionary:
	var validation: Dictionary = _validate(operation, arguments)
	if not validation.ok: return validation
	var result: Dictionary = _dispatch(operation, arguments)
	if result.get("ok", false): module_revision += 1
	result["revision"] = module_revision
	_refresh()
	return result

func _dispatch(operation: String, args: Dictionary) -> Dictionary:
	match operation:
		"animation.speed":
			animation_tree.set("parameters/blend_position", float(args.blend))
			state.blend = float(args.blend)
			return _ok()
		"animation.clip":
			if args.clip not in ["salute", "locomotion"]: return _fail("CLIP_UNAVAILABLE")
			if args.clip == "salute":
				animation_tree.active = false
				animation_player.play("salute")
				state.mode = "salute"
			else:
				animation_player.stop()
				animation_tree.active = true
				state.mode = "locomotion"
			return _ok()
		"animation.advance":
			if animation_tree.active: animation_tree.advance(float(args.seconds))
			else: animation_player.advance(float(args.seconds))
			state.samples += 1
			return _ok({"actual_position": sample.position})
		"particles.configure":
			particles.amount = int(args.amount)
			particles.lifetime = float(args.lifetime)
			particles.gravity = Vector3(0, -6, 0) if args.mode == "rain" else Vector3(0, -0.4, 0)
			particles.initial_velocity_min = 2.0 if args.mode == "rain" else 0.5
			particles.initial_velocity_max = 3.0 if args.mode == "rain" else 1.0
			state.mode = args.mode
			return _ok()
		"particles.emit":
			particles.emitting = args.enabled
			if args.enabled: particles.restart()
			return _ok()
		"particles.backend":
			return _fail("CAPABILITY_UNAVAILABLE", {"reason": "GPU route not qualified; actual emitter is CPUParticles3D"}) if args.backend == "gpu" else _ok({"backend": "CPUParticles3D"})
		"camera.projection":
			preview_camera.projection = Camera3D.PROJECTION_ORTHOGONAL if args.mode == "orthographic" else Camera3D.PROJECTION_PERSPECTIVE
			preview_camera.size = 5.0
			return _ok()
		"camera.arm":
			arm.spring_length = float(args.meters)
			ray.force_raycast_update()
			return _ok()
		"camera.target":
			if args.target != "courier": return _fail("TARGET_NOT_FOUND")
			return _ok({"target": "courier"})
		"terrain.generate":
			_push_history({"samples": terrain_samples.duplicate(), "state": state.duplicate(true)})
			_generate_terrain(int(args.seed), float(args.amplitude))
			state.seed = int(args.seed)
			state.amplitude = float(args.amplitude)
			return _ok()
		"terrain.sculpt":
			_push_history({"samples": terrain_samples.duplicate(), "state": state.duplicate(true)})
			terrain_samples[int(args.z) * 9 + int(args.x)] = float(args.height)
			_rebuild_terrain()
			return _ok()
		"terrain.undo", "atlas.undo", "vertex.undo", "tactics.undo": return _undo()
		"crowd.populate":
			_build_crowd(int(args.count), int(args.seed))
			state.seed = int(args.seed)
			return _ok()
		"crowd.tint":
			for index: int in range(crowd.multimesh.instance_count): crowd.multimesh.set_instance_color(index, MINT if args.palette == "mint" else CORAL)
			state.palette = args.palette
			return _ok()
		"crowd.clear":
			crowd.multimesh.instance_count = 0
			crowd_transforms.clear()
			return _ok()
		"shader.uniform":
			if args.name != "contrast": return _fail("UNKNOWN_UNIFORM")
			shader_material.set_shader_parameter("contrast", float(args.value))
			return _ok()
		"shader.profile":
			if args.profile != "original": return _fail("SHADER_RECIPE_REJECTED", {"preserved": "original"})
			shader_material.shader = preload("res://labs/visual/motif.gdshader")
			shader_material.set_shader_parameter("contrast", 0.5)
			return _ok()
		"garden.generate":
			if not _generate_garden(int(args.seed), float(args.density), false): return _fail("CONNECTIVITY_FAILED")
			state.seed = int(args.seed)
			state.density = float(args.density)
			state.walk_index = 0
			return _ok()
		"garden.variant":
			if not _generate_garden(int(state.seed), float(state.density), args.variant == "sealed"): return _fail("CONNECTIVITY_FAILED")
			return _ok()
		"garden.walk":
			var route: Array[Vector2i] = pathfinder.get_id_path(Vector2i.ZERO, Vector2i(7, 7))
			if route.is_empty(): return _fail("NO_PATH")
			state.walk_index = mini(int(state.walk_index) + 1, route.size() - 1)
			var cell: Vector2i = route[int(state.walk_index)]
			sample.position = Vector3(float(cell.x) - 3.5, 0.8, float(cell.y) - 3.5)
			return _ok({"cell": cell})
		"tactics.preview":
			var target := Vector2i(int(args.x), int(args.y))
			if pathfinder.is_point_solid(target): return _fail("TARGET_OCCUPIED")
			var route: Array[Vector2i] = pathfinder.get_id_path(Vector2i(int(state.x), int(state.y)), target)
			if route.is_empty(): return _fail("NO_PATH")
			var cost: int = route.size() - 1
			if cost > int(state.budget): return _fail("MOVEMENT_BUDGET")
			proposal = {"x": args.x, "y": args.y, "cost": cost, "revision": module_revision + 1}
			state.preview_cost = cost
			return _ok({"path": route, "cost": cost})
		"tactics.commit":
			if proposal.is_empty(): return _fail("NO_TURN_PROPOSAL")
			if int(proposal.revision) != module_revision: return _fail("STALE_PROPOSAL")
			_push_history({"state": state.duplicate(true)})
			state.x = proposal.x
			state.y = proposal.y
			state.budget -= int(proposal.cost)
			state.turn += 1
			proposal.clear()
			sample.position = Vector3(float(state.x) - 3.5, 0.8, float(state.y) - 3.5)
			return _ok()
		"tactics.wait":
			state.turn += 1
			return _ok()
		"atlas.paint":
			if int(args.x) < 8 or int(args.x) > 23 or int(args.y) < 8 or int(args.y) > 23: return _fail("OUTSIDE_MOTIF_REGION")
			_push_history({"bytes": image.get_data(), "state": state.duplicate(true)})
			image.set_pixel(int(args.x), int(args.y), _palette(String(args.color)))
			texture.update(image)
			return _ok()
		"atlas.sampling":
			var surface: StandardMaterial3D = sample.material_override
			surface.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST if args.mode == "nearest" else BaseMaterial3D.TEXTURE_FILTER_LINEAR
			state.sampling = args.mode
			return _ok()
		"vertex.paint":
			_push_history({"colors": vertex_colors.duplicate(), "state": state.duplicate(true)})
			vertex_colors[int(args.vertex)] = _palette(String(args.color))
			_build_vertices()
			return _ok()
		"vertex.ramp":
			_push_history({"colors": vertex_colors.duplicate(), "state": state.duplicate(true)})
			for index: int in range(vertex_colors.size()): vertex_colors[index] = INK.lerp(MINT, clampf((vertex_positions[index].y + 0.8) / 3.0 * float(args.amount), 0, 1))
			_build_vertices()
			state.ramp = float(args.amount)
			return _ok()
		"viewport.source":
			if args.source not in ["front", "side"]: return _fail("INVALID_VIEWPORT_SOURCE")
			preview_camera.position = Vector3(4, 3, 5) if args.source == "front" else Vector3(-5, 2, 1)
			preview_camera.look_at(Vector3(0, 1, 0))
			state.source = args.source
			return _ok()
		"viewport.turn":
			preview.get_node("Miniature").rotation_degrees.y = float(args.degrees)
			state.angle = float(args.degrees)
			return _ok()
		"viewport.recursion":
			if int(args.depth) > 1: return _fail("RECURSION_BUDGET")
			state.depth = int(args.depth)
			return _ok({"actual_nested_viewports": 0, "route": "single monitor fixture"})
		"display.resolution":
			if int(args.width) * 9 != int(args.height) * 16: return _fail("ASPECT_RATIO_REJECTED")
			preview.size = Vector2i(int(args.width), int(args.height))
			return _ok()
		"display.profile":
			display_material.set_shader_parameter("crt_enabled", args.profile == "crt")
			state.profile = args.profile
			return _ok()
	return _fail("UNKNOWN_OPERATION")

func observe() -> Dictionary:
	var result: Dictionary = state.duplicate(true)
	result.revision = module_revision
	result.undo_depth = history.size()
	match lab_id:
		"LAB-008":
			result.tree_blend = animation_tree.get("parameters/blend_position")
			result.tree_active = animation_tree.active
			result.actual_animation = animation_player.current_animation
			result.pose_y = sample.position.y
		"LAB-009":
			result.amount = particles.amount
			result.lifetime = particles.lifetime
			result.emitting = particles.emitting
			result.backend = particles.get_class()
		"LAB-011":
			result.projection = "orthographic" if preview_camera.projection == Camera3D.PROJECTION_ORTHOGONAL else "perspective"
			result.spring_length = arm.spring_length
			result.hit_length = arm.get_hit_length()
			result.raycast_hit = ray.is_colliding()
		"LAB-016":
			result.sample_count = terrain_samples.size()
			result.height_hash = terrain_samples.to_byte_array().hex_encode().sha256_text()
			result.center_height = terrain_samples[40]
			result.mesh_surfaces = terrain_mesh.mesh.get_surface_count()
			result.collider_count = terrain_body.get_child(0).shape.map_data.size()
		"LAB-017":
			result.count = crowd.multimesh.instance_count
			result.transform_hash = _crowd_hash()
			result.renderer_readback_available = DisplayServer.get_name() != "headless"
			result.frame_seconds = Performance.get_monitor(Performance.TIME_PROCESS)
			result.metric_scope = "host process timing; renderer draw calls require rendered gate"
		"LAB-019":
			result.contrast = shader_material.get_shader_parameter("contrast")
			result.reference_color = reference.material_override.albedo_color.to_html()
			result.shader_source = shader_material.shader.resource_path
		"LAB-023":
			result.path_length = pathfinder.get_id_path(Vector2i.ZERO, Vector2i(7, 7)).size()
			result.blocked = grid_blocks.size()
			result.topology_hash = _grid_hash()
		"LAB-055": result.blocked = grid_blocks.size()
		"LAB-060":
			result.atlas_hash = image.get_data().hex_encode().sha256_text()
			result.width = texture.get_width()
			result.padding_pixel = image.get_pixel(0, 0).to_html()
		"LAB-061":
			var tool := MeshDataTool.new()
			var error: Error = tool.create_from_surface(sample.mesh, 0)
			result.attribute_read_ok = error == OK
			result.mesh_vertices = tool.get_vertex_count() if error == OK else -1
			result.color_hash = _color_hash()
		"LAB-066", "LAB-068":
			result.viewport_width = preview.size.x
			result.viewport_height = preview.size.y
			result.camera_current = preview_camera.current
			result.simulation_hz = Engine.physics_ticks_per_second
			if display_material != null: result.crt_enabled = display_material.get_shader_parameter("crt_enabled")
	return result

func reset() -> Dictionary:
	history.clear()
	proposal.clear()
	module_revision = 0
	match lab_id:
		"LAB-008":
			state = {"blend": 0.0, "mode": "locomotion", "samples": 0}
			animation_player.stop()
			animation_tree.active = true
			animation_tree.set("parameters/blend_position", 0.0)
			animation_tree.advance(0.01)
		"LAB-009":
			state = {"mode": "rain"}
			particles.emitting = false
			particles.amount = 32
			particles.lifetime = 1.0
			particles.gravity = Vector3(0, -6, 0)
		"LAB-011":
			state = {"target": "courier"}
			preview_camera.projection = Camera3D.PROJECTION_PERSPECTIVE
			arm.spring_length = 6.0
		"LAB-016":
			state = {"seed": 17, "amplitude": 1.0}
			_generate_terrain(17, 1.0)
		"LAB-017":
			state = {"seed": 17, "palette": "mint"}
			_build_crowd(24, 17)
		"LAB-019":
			state = {"profile": "original"}
			shader_material.set_shader_parameter("contrast", 0.5)
		"LAB-023":
			state = {"seed": 17, "density": 0.25, "walk_index": 0}
			_generate_garden(17, 0.25, false)
		"LAB-055":
			state = {"x": 0, "y": 0, "budget": 6, "turn": 0, "preview_cost": 0}
			sample.position = Vector3(-3.5, 0.8, -3.5)
		"LAB-060":
			state = {"sampling": "nearest"}
			_build_atlas()
		"LAB-061":
			state = {"ramp": 1.0}
			vertex_colors = [INK, STONE, STONE, INK, MINT, GOLD]
			_build_vertices()
		"LAB-066":
			state = {"source": "front", "angle": 0.0, "depth": 0}
			preview_camera.position = Vector3(4, 3, 5)
			preview_camera.look_at(Vector3(0, 1, 0))
			preview.get_node("Miniature").rotation = Vector3.ZERO
		"LAB-068":
			state = {"profile": "clean"}
			preview.size = Vector2i(512, 288)
			display_material.set_shader_parameter("crt_enabled", false)
	_refresh()
	return _ok()

func teardown() -> void:
	if particles != null: particles.emitting = false
	if animation_tree != null: animation_tree.active = false
	if animation_player != null: animation_player.stop()
	proposal.clear()
	super.teardown()

func _courier(at: Vector3) -> MeshInstance3D:
	var courier := MeshInstance3D.new()
	courier.position = at
	var mesh := PrismMesh.new()
	mesh.size = Vector3(1.2, 1.6, 1.8)
	courier.mesh = mesh
	courier.material_override = material(CORAL)
	fixture.add_child(courier)
	for side: float in [-0.8, 0.8]:
		var wing := MeshInstance3D.new()
		var wing_mesh := BoxMesh.new()
		wing_mesh.size = Vector3(0.5, 0.2, 1.7)
		wing.mesh = wing_mesh
		wing.position = Vector3(side, 0.1, 0)
		wing.material_override = material(GOLD)
		courier.add_child(wing)
	return courier

func _banner(at: Vector3, color: Color) -> MeshInstance3D:
	var banner := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(2.6, 3.0, 0.3)
	banner.mesh = mesh
	banner.position = at
	banner.material_override = material(color)
	fixture.add_child(banner)
	box(at + Vector3(0, 1.7, 0), Vector3(3.3, 0.3, 0.6), GOLD)
	return banner

func _build_animation() -> void:
	sample = _courier(Vector3(0, 1.2, -2))
	sample.name = "Courier"
	animation_player = AnimationPlayer.new()
	animation_player.name = "AnimationPlayer"
	fixture.add_child(animation_player)
	var library := AnimationLibrary.new()
	for clip: String in ["idle", "walk", "salute"]:
		var animation := Animation.new()
		animation.length = 0.8 if clip == "salute" else 0.5
		animation.loop_mode = Animation.LOOP_NONE if clip == "salute" else Animation.LOOP_LINEAR
		var track: int = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track, NodePath("Courier:rotation" if clip == "salute" else "Courier:position"))
		if clip == "salute":
			animation.track_insert_key(track, 0.0, Vector3.ZERO)
			animation.track_insert_key(track, 0.4, Vector3(0, 0, -0.65))
			animation.track_insert_key(track, 0.8, Vector3.ZERO)
		else:
			animation.track_insert_key(track, 0.0, Vector3(0, 1.2, -2))
			animation.track_insert_key(track, 0.25, Vector3(0, 1.45 if clip == "walk" else 1.2, -2))
			animation.track_insert_key(track, 0.5, Vector3(0, 1.2, -2))
		library.add_animation(clip, animation)
	animation_player.add_animation_library("", library)
	animation_player.animation_finished.connect(func(clip: StringName) -> void:
		if clip == &"salute":
			animation_tree.active = true
			state.mode = "locomotion")
	animation_tree = AnimationTree.new()
	fixture.add_child(animation_tree)
	animation_tree.anim_player = animation_tree.get_path_to(animation_player)
	var space := AnimationNodeBlendSpace1D.new()
	space.min_space = 0.0
	space.max_space = 1.0
	var idle := AnimationNodeAnimation.new()
	idle.animation = &"idle"
	var walk := AnimationNodeAnimation.new()
	walk.animation = &"walk"
	space.add_blend_point(idle, 0, -1, &"idle")
	space.add_blend_point(walk, 1, -1, &"walk")
	animation_tree.tree_root = space
	animation_tree.active = true

func _build_particles() -> void:
	box(Vector3(0, 0.3, -1), Vector3(6, 0.6, 5), INK)
	for x: float in [-3, 3]: box(Vector3(x, 2, -1), Vector3(0.3, 4, 0.3), GOLD)
	box(Vector3(0, 4, -1), Vector3(6.6, 0.3, 0.8), GOLD)
	particles = CPUParticles3D.new()
	particles.position = Vector3(0, 3.5, -1)
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	particles.emission_box_extents = Vector3(2.5, 0.1, 1.8)
	particles.direction = Vector3.DOWN
	particles.spread = 12
	particles.color = MINT
	var mesh := SphereMesh.new()
	mesh.radius = 0.055
	mesh.height = 0.15
	mesh.radial_segments = 6
	mesh.rings = 3
	mesh.material = material(MINT, true)
	particles.mesh = mesh
	particles.emitting = false
	fixture.add_child(particles)

func _generate_terrain(seed_value: int, amplitude: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	terrain_samples.resize(81)
	for z: int in range(9):
		for x: int in range(9):
			var distance: float = Vector2(float(x - 4), float(z - 4)).length() / 5.7
			terrain_samples[z * 9 + x] = maxf(0, (1.0 - distance) * amplitude + rng.randf_range(-0.1, 0.1) * amplitude) + 0.15
	_rebuild_terrain()

func _rebuild_terrain() -> void:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()
	for z: int in range(9):
		for x: int in range(9):
			vertices.append(Vector3(float(x - 4), terrain_samples[z * 9 + x], float(z - 4)))
			normals.append(Vector3.UP)
			var height: float = terrain_samples[z * 9 + x]
			var shade: Color = MINT if height < 0.5 else (GOLD if height < 1.6 else CORAL)
			if x == 0 or x == 8 or z == 0 or z == 8: shade = INK
			colors.append(shade)
	for z: int in range(8):
		for x: int in range(8):
			var a: int = z * 9 + x
			# Godot front faces use clockwise winding, viewed from above the island.
			indices.append_array(PackedInt32Array([a, a + 1, a + 9, a + 1, a + 10, a + 9]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	terrain_mesh.mesh = mesh
	var surface: StandardMaterial3D = material(Color.WHITE)
	surface.vertex_color_use_as_albedo = true
	terrain_mesh.material_override = surface
	var shape := HeightMapShape3D.new()
	shape.map_width = 9
	shape.map_depth = 9
	shape.map_data = terrain_samples
	terrain_body.get_child(0).shape = shape

func _build_crowd(count: int, seed_value: int) -> void:
	crowd_transforms.clear()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.2
	mesh.bottom_radius = 0.35
	mesh.height = 0.8
	mesh.radial_segments = 6
	var surface: StandardMaterial3D = material(Color.WHITE)
	surface.vertex_color_use_as_albedo = true
	mesh.material = surface
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.use_colors = true
	multi.mesh = mesh
	multi.instance_count = count
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for index: int in range(count):
		var at := Vector3(float(index % 12) - 5.5, 0.65 + rng.randf_range(0, 0.3), float(index / 12) * 0.9 - 4)
		var transform := Transform3D(Basis(Vector3.UP, rng.randf_range(-0.2, 0.2)), at)
		crowd_transforms.append(transform)
		multi.set_instance_transform(index, transform)
		multi.set_instance_color(index, MINT if index % 2 == 0 else GOLD)
	crowd.multimesh = multi

func _generate_garden(seed_value: int, density: float, sealed: bool) -> bool:
	var candidate := AStarGrid2D.new()
	candidate.region = Rect2i(0, 0, 8, 8)
	candidate.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	candidate.update()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var blocks: Array[Vector2i] = []
	for y: int in range(8):
		for x: int in range(8):
			if (x > 0 and y < 7 and rng.randf() < density) or (sealed and y == 4):
				candidate.set_point_solid(Vector2i(x, y))
				blocks.append(Vector2i(x, y))
	if candidate.get_id_path(Vector2i.ZERO, Vector2i(7, 7)).is_empty(): return false
	pathfinder = candidate
	grid_blocks = blocks
	_apply_grid()
	return true

func _apply_grid() -> void:
	for visual: Node3D in grid_visuals: visual.queue_free()
	grid_visuals.clear()
	pathfinder.fill_solid_region(Rect2i(0, 0, 8, 8), false)
	for cell: Vector2i in grid_blocks: pathfinder.set_point_solid(cell)
	for y: int in range(8):
		for x: int in range(8):
			var blocked: bool = Vector2i(x, y) in grid_blocks
			var visual: MeshInstance3D = box(Vector3(float(x) - 3.5, 0.3 if blocked else 0.06, float(y) - 3.5), Vector3(0.9, 0.6 if blocked else 0.12, 0.9), GOLD if blocked else STONE)
			grid_visuals.append(visual)

func _build_atlas() -> void:
	image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(STONE)
	for x: int in range(8, 24):
		for y: int in range(8, 24): image.set_pixel(x, y, GOLD if (x + y) % 8 < 2 else MINT)
	texture = ImageTexture.create_from_image(image)
	var surface: StandardMaterial3D = material(Color.WHITE)
	surface.albedo_texture = texture
	surface.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sample.material_override = surface

func _build_vertices() -> void:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var triangles: Array[int] = [0, 4, 1, 1, 4, 2, 2, 4, 3, 3, 4, 0, 1, 5, 0, 2, 5, 1, 3, 5, 2, 0, 5, 3]
	for index: int in triangles:
		tool.set_color(vertex_colors[index])
		tool.add_vertex(vertex_positions[index])
	tool.generate_normals()
	sample.mesh = tool.commit()
	var surface: StandardMaterial3D = material(Color.WHITE)
	surface.vertex_color_use_as_albedo = true
	surface.cull_mode = BaseMaterial3D.CULL_DISABLED
	sample.material_override = surface

func _build_preview(shared_world: bool) -> void:
	preview = SubViewport.new()
	preview.size = Vector2i(512, 288)
	preview.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(preview)
	if shared_world:
		preview.world_3d = get_world_3d()
		var pivot := Node3D.new()
		pivot.position = Vector3(0, 2, -2)
		preview.add_child(pivot)
		arm = SpringArm3D.new()
		arm.spring_length = 6
		arm.margin = 0.2
		pivot.add_child(arm)
		preview_camera = Camera3D.new()
		arm.add_child(preview_camera)
		ray = RayCast3D.new()
		ray.target_position = Vector3(0, 0, 8)
		ray.enabled = true
		pivot.add_child(ray)
	else:
		preview.own_world_3d = true
		var miniature := Node3D.new()
		miniature.name = "Miniature"
		preview.add_child(miniature)
		for index: int in range(6):
			var tower := MeshInstance3D.new()
			var mesh := PrismMesh.new()
			mesh.size = Vector3(0.6, 1.0 + float(index % 3) * 0.4, 0.8)
			tower.mesh = mesh
			tower.position = Vector3(float(index % 3) - 1.0, 0.5, float(index / 3) - 0.5)
			tower.material_override = shader_material if lab_id == "LAB-019" else material([MINT, CORAL, GOLD][index % 3])
			miniature.add_child(tower)
		var light := DirectionalLight3D.new()
		light.rotation_degrees = Vector3(-45, -30, 0)
		preview.add_child(light)
		preview_camera = Camera3D.new()
		preview_camera.position = Vector3(4, 3, 5)
		preview.add_child(preview_camera)
		preview_camera.look_at(Vector3(0, 1, 0))
	preview_camera.current = true
	if lab_id == "LAB-068":
		display_material = ShaderMaterial.new()
		display_material.shader = preload("res://labs/visual/display.gdshader")

func _push_history(value: Dictionary) -> void:
	if history.size() >= 16: history.pop_front()
	history.append(value)

func _undo() -> Dictionary:
	if history.is_empty(): return _fail("UNDO_EMPTY")
	var before: Dictionary = history.pop_back()
	state = before.state
	proposal.clear()
	match lab_id:
		"LAB-016":
			terrain_samples = before.samples
			_rebuild_terrain()
		"LAB-060":
			image = Image.create_from_data(32, 32, false, Image.FORMAT_RGBA8, before.bytes)
			texture.update(image)
			var surface: StandardMaterial3D = sample.material_override
			surface.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST if state.sampling == "nearest" else BaseMaterial3D.TEXTURE_FILTER_LINEAR
		"LAB-061":
			vertex_colors = before.colors
			_build_vertices()
		"LAB-055": sample.position = Vector3(float(state.x) - 3.5, 0.8, float(state.y) - 3.5)
	return _ok()

func _crowd_hash() -> String:
	var record: String = ""
	for transform: Transform3D in crowd_transforms: record += str(transform)
	return record.sha256_text()
func _grid_hash() -> String: return str(grid_blocks).sha256_text()
func _color_hash() -> String: return str(vertex_colors).sha256_text()
func _palette(color: String) -> Color: return {"ink": INK, "stone": STONE, "mint": MINT, "gold": GOLD, "coral": CORAL}[color]
func _ok(extra: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {"ok": true, "code": "APPLIED"}
	result.merge(extra)
	return result
func _fail(code: String, extra: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {"ok": false, "code": code}
	result.merge(extra)
	return result
func _op(name: String, args: Dictionary = {}) -> Dictionary: return {"name": name, "scope": "lab", "arguments": args, "required": args.keys(), "mutates": true}
func _number(low: float, high: float) -> Dictionary: return {"type": "number", "min": low, "max": high}
func _integer(low: int, high: int) -> Dictionary: return {"type": "integer", "min": low, "max": high}
func _enum(values: Array) -> Dictionary: return {"type": "enum", "values": values}
func _string(length: int) -> Dictionary: return {"type": "string", "max_length": length}
func _boolean() -> Dictionary: return {"type": "boolean"}

func _validate(name: String, args: Dictionary) -> Dictionary:
	var schema: Dictionary = {}
	var found: bool = false
	for descriptor: Dictionary in operations():
		if descriptor.name == name:
			found = true
			schema = descriptor.arguments
	if not found: return _fail("UNKNOWN_OPERATION")
	if args.size() != schema.size(): return _fail("INVALID_ARGUMENT_FIELDS")
	for key: String in schema:
		if not args.has(key): return _fail("MISSING_ARGUMENT")
		var value: Variant = args[key]
		var rule: Dictionary = schema[key]
		match String(rule.type):
			"integer":
				if not value is int or int(value) < int(rule.min) or int(value) > int(rule.max): return _fail("INVALID_ARGUMENT")
			"number":
				if (not value is int and not value is float) or not is_finite(float(value)) or float(value) < float(rule.min) or float(value) > float(rule.max): return _fail("INVALID_ARGUMENT")
			"string":
				if not value is String or String(value).length() > int(rule.max_length): return _fail("INVALID_ARGUMENT")
			"enum":
				if value not in rule.values: return _fail("INVALID_ARGUMENT")
			"boolean":
				if not value is bool: return _fail("INVALID_ARGUMENT")
	return _ok()

func _refresh() -> void:
	if is_instance_valid(readout): readout.text = JSON.stringify(observe(), "  ")

func primary_operation() -> Dictionary:
	match lab_id:
		"LAB-008": return _action("animation.clip", {"clip": "salute"})
		"LAB-009": return _action("particles.emit", {"enabled": not particles.emitting})
		"LAB-011": return _action("camera.projection", {"mode": "orthographic" if preview_camera.projection == Camera3D.PROJECTION_PERSPECTIVE else "perspective"})
		"LAB-016": return _action("terrain.generate", {"seed": int(state.seed) + 1, "amplitude": 1.5})
		"LAB-017": return _action("crowd.populate", {"count": 72, "seed": 42})
		"LAB-019": return _action("shader.uniform", {"name": "contrast", "value": 1.0})
		"LAB-023": return _action("garden.walk")
		"LAB-055": return _action("tactics.commit") if not proposal.is_empty() else _action("tactics.preview", {"x": 1, "y": 2})
		"LAB-060": return _action("atlas.paint", {"x": 16, "y": 16, "color": "coral"})
		"LAB-061": return _action("vertex.paint", {"vertex": 4, "color": "coral"})
		"LAB-066": return _action("viewport.source", {"source": "side" if state.source == "front" else "front"})
		"LAB-068": return _action("display.profile", {"profile": "crt" if state.profile == "clean" else "clean"})
	return {}

func create_controls(parent: Control) -> void:
	var existing: Array[Node] = parent.get_children()
	var note := Label.new()
	note.text = String(NOTES.get(lab_id, ""))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.custom_minimum_size.x = 300
	parent.add_child(note)
	if preview != null:
		preview_texture = TextureRect.new()
		preview_texture.texture = preview.get_texture()
		preview_texture.custom_minimum_size = Vector2(320, 180)
		preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		preview_texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if display_material != null: preview_texture.material = display_material
		parent.add_child(preview_texture)
	var grid := GridContainer.new()
	grid.columns = 2
	parent.add_child(grid)
	match lab_id:
		"LAB-008":
			_parameters(parent, "animation.speed", {"blend": 0.5})
			_button(grid, "Brass salute", "animation.clip", {"clip": "salute"})
			_button(grid, "Interrupt / locomotion", "animation.clip", {"clip": "locomotion"})
			_button(grid, "Sample +0.25 seconds", "animation.advance", {"seconds": 0.25})
		"LAB-009":
			_parameters(parent, "particles.configure", {"amount": 64, "lifetime": 1.5, "mode": "rain"})
			_button(grid, "Start CPU weather", "particles.emit", {"enabled": true})
			_button(grid, "Stop weather", "particles.emit", {"enabled": false})
			_button(grid, "Probe GPU route", "particles.backend", {"backend": "gpu"})
		"LAB-011":
			_parameters(parent, "camera.arm", {"meters": 6.0})
			for mode: String in ["perspective", "orthographic"]: _button(grid, mode.capitalize(), "camera.projection", {"mode": mode})
		"LAB-016":
			_parameters(parent, "terrain.generate", {"seed": 42, "amplitude": 1.0})
			_parameters(parent, "terrain.sculpt", {"x": 4, "z": 4, "height": 2.0})
			_button(grid, "Undo terrain", "terrain.undo")
		"LAB-017":
			_parameters(parent, "crowd.populate", {"count": 48, "seed": 42})
			for palette: String in ["mint", "coral"]: _button(grid, "Tint " + palette, "crowd.tint", {"palette": palette})
			_button(grid, "Release crowd", "crowd.clear")
		"LAB-019":
			_parameters(parent, "shader.uniform", {"name": "contrast", "value": 0.7})
			_button(grid, "Restore original shader", "shader.profile", {"profile": "original"})
			_button(grid, "Reject unknown recipe", "shader.profile", {"profile": "invalid"})
		"LAB-023":
			_parameters(parent, "garden.generate", {"seed": 42, "density": 0.3})
			_button(grid, "Walk connected path", "garden.walk")
			_button(grid, "Reject sealed proposal", "garden.variant", {"variant": "sealed"})
		"LAB-055":
			_parameters(parent, "tactics.preview", {"x": 1, "y": 2})
			_button(grid, "Commit turn", "tactics.commit")
			_button(grid, "Wait / stale preview", "tactics.wait")
			_button(grid, "Undo turn", "tactics.undo")
		"LAB-060":
			_parameters(parent, "atlas.paint", {"x": 16, "y": 16, "color": "coral"})
			_button(grid, "Undo pixel", "atlas.undo")
			for mode: String in ["nearest", "linear"]: _button(grid, mode.capitalize() + " sample", "atlas.sampling", {"mode": mode})
		"LAB-061":
			_parameters(parent, "vertex.paint", {"vertex": 4, "color": "coral"})
			_parameters(parent, "vertex.ramp", {"amount": 0.7})
			_button(grid, "Undo vertex colors", "vertex.undo")
		"LAB-066":
			for source: String in ["front", "side"]: _button(grid, "Camera " + source, "viewport.source", {"source": source})
			_parameters(parent, "viewport.turn", {"degrees": 45.0})
			_button(grid, "Probe recursion cap", "viewport.recursion", {"depth": 2})
		"LAB-068":
			for resolution: Vector2i in [Vector2i(128, 72), Vector2i(256, 144), Vector2i(512, 288)]: _button(grid, "%s x %s" % [resolution.x, resolution.y], "display.resolution", {"width": resolution.x, "height": resolution.y})
			for profile: String in ["clean", "crt"]: _button(grid, profile.capitalize(), "display.profile", {"profile": profile})
	readout = RichTextLabel.new()
	readout.fit_content = true
	readout.scroll_active = false
	readout.custom_minimum_size.x = 300
	parent.add_child(readout)
	_refresh()
	for child: Node in parent.get_children():
		if child not in existing: _controls.append(child)

func _parameters(parent: Control, operation: String, defaults: Dictionary) -> void:
	var box_ui := VBoxContainer.new()
	parent.add_child(box_ui)
	var fields: Dictionary = {}
	var schema: Dictionary = {}
	for descriptor: Dictionary in operations():
		if descriptor.name == operation: schema = descriptor.arguments
	for key: String in defaults:
		var row := HBoxContainer.new()
		box_ui.add_child(row)
		var label := Label.new()
		label.text = key.capitalize()
		label.custom_minimum_size.x = 100
		row.add_child(label)
		var rule: Dictionary = schema[key]
		var control: Control
		if rule.type in ["integer", "number"]:
			var spin := SpinBox.new()
			spin.min_value = float(rule.min)
			spin.max_value = float(rule.max)
			spin.step = 1.0 if rule.type == "integer" else 0.05
			spin.value = float(defaults[key])
			control = spin
		elif rule.type == "enum":
			var option := OptionButton.new()
			for value: String in rule.values: option.add_item(value)
			option.select(rule.values.find(defaults[key]))
			control = option
		else:
			var line := LineEdit.new()
			line.text = String(defaults[key])
			line.max_length = int(rule.max_length)
			control = line
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(control)
		fields[key] = control
	var apply := Button.new()
	apply.text = "Apply " + operation
	box_ui.add_child(apply)
	apply.pressed.connect(func() -> void:
		var args: Dictionary = {}
		for key: String in fields:
			var field: Control = fields[key]
			var rule: Dictionary = schema[key]
			if field is SpinBox: args[key] = int(field.value) if rule.type == "integer" else float(field.value)
			elif field is OptionButton: args[key] = field.get_item_text(field.selected)
			elif field is LineEdit: args[key] = field.text
		request_operation.emit(operation, args))

func _button(parent: Control, text: String, operation: String, args: Dictionary = {}) -> Button:
	var button := Button.new()
	button.text = text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(func() -> void: request_operation.emit(operation, args.duplicate(true)))
	parent.add_child(button)
	return button

func _action(operation: String, args: Dictionary = {}) -> Dictionary: return {"operation": operation, "arguments": args}
func _step(operation: String, args: Dictionary = {}, assertions: Dictionary = {}, ok: bool = true, code: String = "") -> Dictionary:
	var step: Dictionary = {"operation": operation, "arguments": args, "expect_ok": ok, "assert": assertions}
	if not code.is_empty(): step.expect_code = code
	return step

func scenario() -> Array[Dictionary]:
	match lab_id:
		"LAB-008": return [_step("animation.speed", {"blend": 0.75}, {"tree_blend": 0.75}), _step("animation.clip", {"clip": "salute"}, {"mode": "salute", "tree_active": false}), _step("animation.advance", {"seconds": 1.0}, {"mode": "locomotion", "tree_active": true}), _step("animation.clip", {"clip": "missing"}, {}, false, "CLIP_UNAVAILABLE"), _step("animation.speed", {"blend": 2.0}, {}, false, "INVALID_ARGUMENT")]
		"LAB-009": return [_step("particles.configure", {"amount": 64, "lifetime": 2.0, "mode": "blossom"}, {"amount": 64, "lifetime": 2.0}), _step("particles.emit", {"enabled": true}, {"emitting": true}), _step("particles.emit", {"enabled": false}, {"emitting": false}), _step("particles.backend", {"backend": "gpu"}, {}, false, "CAPABILITY_UNAVAILABLE"), _step("particles.configure", {"amount": 256, "lifetime": 1.0, "mode": "rain"}, {}, false, "INVALID_ARGUMENT")]
		"LAB-011": return [_step("camera.target", {"target": "courier"}), _step("camera.projection", {"mode": "orthographic"}, {"projection": "orthographic"}), _step("camera.arm", {"meters": 3.0}, {"spring_length": 3.0}), _step("camera.target", {"target": "missing"}, {}, false, "TARGET_NOT_FOUND"), _step("camera.arm", {"meters": -1.0}, {}, false, "INVALID_ARGUMENT")]
		"LAB-016": return [_step("terrain.generate", {"seed": 42, "amplitude": 0.5}, {"seed": 42, "sample_count": 81, "collider_count": 81}), _step("terrain.sculpt", {"x": 4, "z": 4, "height": 2.0}, {"center_height": 2.0}), _step("terrain.undo", {}, {"seed": 42}), _step("terrain.sculpt", {"x": 9, "z": 4, "height": 1.0}, {}, false, "INVALID_ARGUMENT"), _step("terrain.generate", {"seed": -1, "amplitude": 1.0}, {}, false, "INVALID_ARGUMENT")]
		"LAB-017": return [_step("crowd.populate", {"count": 48, "seed": 42}, {"count": 48}), _step("crowd.tint", {"palette": "coral"}, {"palette": "coral"}), _step("crowd.clear", {}, {"count": 0}), _step("crowd.populate", {"count": 129, "seed": 42}, {}, false, "INVALID_ARGUMENT"), _step("crowd.tint", {"palette": "unknown"}, {}, false, "INVALID_ARGUMENT")]
		"LAB-019": return [_step("shader.uniform", {"name": "contrast", "value": 0.0}, {"contrast": 0.0}), _step("shader.uniform", {"name": "contrast", "value": 1.0}, {"contrast": 1.0}), _step("shader.profile", {"profile": "original"}, {"contrast": 0.5}), _step("shader.uniform", {"name": "missing", "value": 0.5}, {}, false, "UNKNOWN_UNIFORM"), _step("shader.profile", {"profile": "invalid"}, {}, false, "SHADER_RECIPE_REJECTED")]
		"LAB-023": return [_step("garden.generate", {"seed": 42, "density": 0.3}, {"seed": 42, "path_length": 15}), _step("garden.walk", {}, {"walk_index": 1}), _step("garden.variant", {"variant": "connected"}), _step("garden.variant", {"variant": "sealed"}, {}, false, "CONNECTIVITY_FAILED"), _step("garden.generate", {"seed": 42, "density": 2.0}, {}, false, "INVALID_ARGUMENT")]
		"LAB-055": return [_step("tactics.preview", {"x": 1, "y": 2}, {"preview_cost": 3}), _step("tactics.commit", {}, {"x": 1, "y": 2, "budget": 3, "turn": 1}), _step("tactics.undo", {}, {"x": 0, "y": 0, "budget": 6}), _step("tactics.preview", {"x": 2, "y": 0}, {}, false, "TARGET_OCCUPIED"), _step("tactics.preview", {"x": 7, "y": 7}, {}, false, "MOVEMENT_BUDGET"), _step("tactics.preview", {"x": 1, "y": 0}), _step("tactics.wait"), _step("tactics.commit", {}, {}, false, "STALE_PROPOSAL")]
		"LAB-060": return [_step("atlas.paint", {"x": 16, "y": 16, "color": "coral"}, {"width": 32}), _step("atlas.sampling", {"mode": "linear"}, {"sampling": "linear"}), _step("atlas.undo"), _step("atlas.paint", {"x": 0, "y": 0, "color": "gold"}, {}, false, "OUTSIDE_MOTIF_REGION"), _step("atlas.paint", {"x": 33, "y": 16, "color": "mint"}, {}, false, "INVALID_ARGUMENT")]
		"LAB-061": return [_step("vertex.paint", {"vertex": 4, "color": "coral"}, {"mesh_vertices": 24, "attribute_read_ok": true}), _step("vertex.ramp", {"amount": 0.5}, {"ramp": 0.5}), _step("vertex.undo", {}, {"ramp": 1.0}), _step("vertex.paint", {"vertex": 6, "color": "coral"}, {}, false, "INVALID_ARGUMENT"), _step("vertex.ramp", {"amount": -1.0}, {}, false, "INVALID_ARGUMENT")]
		"LAB-066": return [_step("viewport.source", {"source": "side"}, {"source": "side", "camera_current": true}), _step("viewport.turn", {"degrees": 45.0}, {"angle": 45.0}), _step("viewport.recursion", {"depth": 1}, {"depth": 1}), _step("viewport.source", {"source": "desktop"}, {}, false, "INVALID_VIEWPORT_SOURCE"), _step("viewport.recursion", {"depth": 2}, {}, false, "RECURSION_BUDGET")]
		"LAB-068": return [_step("display.resolution", {"width": 256, "height": 144}, {"viewport_width": 256, "viewport_height": 144}), _step("display.profile", {"profile": "crt"}, {"profile": "crt", "crt_enabled": true, "simulation_hz": 60}), _step("display.profile", {"profile": "clean"}, {"profile": "clean", "crt_enabled": false}), _step("display.resolution", {"width": 256, "height": 160}, {}, false, "ASPECT_RATIO_REJECTED"), _step("display.resolution", {"width": 1, "height": 1}, {}, false, "INVALID_ARGUMENT")]
	return []
