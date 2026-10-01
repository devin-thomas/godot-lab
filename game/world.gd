extends Node3D

const SURFACE: Shader = preload("res://art/pixel_surface.gdshader")
const INK: Color = Color("162e40")
const STONE: Color = Color("527875")
const MINT: Color = Color("75dfb8")
const GOLD: Color = Color("e9b75b")
const CORAL: Color = Color("ed8064")
var portals: Array[Vector3] = []
var bodies: Array[RigidBody3D] = []
var material_mode: int = 0
var sample_materials: Array[ShaderMaterial] = []
var sample_labels: Array[Label3D] = []
var audio: AudioStreamPlayer3D
var audio_on: bool = false
var nav_agent: NavigationAgent3D
var nav_actor: CharacterBody3D
var nav_go: bool = false
var nav_arrived: bool = false
var nav_path_peak: int = 0
var active: String = "hub"
var room: Node3D
var clock: float = 0.0
var portal_labels: Array[Label3D] = []


func build_hub() -> void:
	active = "hub"
	_clear()
	portals.clear()
	portal_labels.clear()
	_floor(Vector3.ZERO, Vector3(30, 0.5, 25))
	# Quiet repeated trims carry the architecture; the portals own the contrast.
	for x: int in range(-14, 15, 2):
		_box(Vector3(x, 0.02, 0), Vector3(0.035, 0.035, 24), Color("375a5c"))
	for z: int in range(-12, 13, 2):
		_box(Vector3(0, 0.02, z), Vector3(29, 0.035, 0.035), Color("375a5c"))
	_box(Vector3(0, 0.5, -4), Vector3(3, 1, 3), INK, true)
	_box(Vector3(0, 2.8, -4), Vector3(1.2, 3.5, 1.2), GOLD, true)
	var crystal: MeshInstance3D = MeshInstance3D.new()
	var crystal_mesh: PrismMesh = PrismMesh.new()
	crystal_mesh.size = Vector3(1.7, 1.6, 1.7)
	crystal.mesh = crystal_mesh
	crystal.material_override = _mat(MINT, true)
	crystal.position = Vector3(0, 5.2, -4)
	crystal.rotation.y = PI / 4
	room.add_child(crystal)
	_sign("SIGNAL\nOBSERVATORY", Vector3(0, 4, -3.25), GOLD, 40)
	var names: Array[String] = ["01 / MOTION", "02 / PHYSICS", "03 / NAVIGATION",
		"04 / MATERIALS", "05 / SOUND", "06 / MEMORY"]
	for i: int in range(6):
		var p: Vector3 = Vector3(-10 + (i % 3) * 10, 0, -9 if i < 3 else 6)
		portals.append(p)
		var accent: Color = [MINT, GOLD, CORAL, Color("82a5ce"), MINT, GOLD][i]
		_box(p + Vector3(-1.6, 1.65, 0), Vector3(0.5, 3.3, 0.7), INK, true)
		_box(p + Vector3(1.6, 1.65, 0), Vector3(0.5, 3.3, 0.7), INK, true)
		_box(p + Vector3(0, 3.4, 0), Vector3(3.8, 0.5, 0.7), accent)
		_box(p + Vector3(0, 0.06, 0), Vector3(2.8, 0.1, 2.0), accent)
		portal_labels.append(_sign(names[i], p + Vector3(0, 4.15, 0), accent, 28))
		for j: int in range(4):
			_box(p + Vector3(-1.25 + j * 0.8, 2.7, 0), Vector3(0.18, 0.18, 0.18), accent)
	# Floating silhouette islands instead of an expensive scene-wide post process.
	for i: int in range(12):
		var angle: float = float(i) * TAU / 12
		_box(Vector3(cos(angle) * 32, -3 - i % 3, sin(angle) * 28),
			Vector3(5, 8 + i % 4, 5), INK)


func build_module_room(id: String) -> void:
	active = id
	_clear()
	portals.clear()
	portal_labels.clear()


func build_lab(id: String) -> void:
	active = id
	_clear()
	_floor(Vector3.ZERO, Vector3(24, 0.5, 20))
	for x: int in [-12, 12]:
		_box(Vector3(x, 1, 0), Vector3(0.5, 2, 20), INK, true)
	_box(Vector3(0, 1, -10), Vector3(24, 2, 0.5), INK, true)
	_box(Vector3(0, 1, 10), Vector3(24, 2, 0.5), INK, true)
	for x: int in range(-10, 11, 4):
		_box(Vector3(x, 2.4, -9.3), Vector3(0.6, 4.8, 0.6), STONE, true)
	match id:
		"motion":
			for i: int in range(5):
				_box(Vector3(-5 + i * 2.2, 0.25 + i * 0.18, -2),
					Vector3(1.6, 0.5 + i * 0.36, 2.2), GOLD, true)
			_sign("MOVE / JUMP / LAND", Vector3(0, 4, -7), MINT, 48)
			_box(Vector3(0, 1, 2), Vector3(2, 2, 2), CORAL, true)
		"physics":
			_sign("EVERY BODY HAS WEIGHT", Vector3(0, 4.5, -7), GOLD, 40)
			for i: int in range(6):
				_spawn_body(Vector3(-2 + (i % 3) * 1.4, 1 + (i / 3) * 1.4, -2))
			_box(Vector3(4, 0.6, -2), Vector3(3, 1.2, 3), INK, true)
		"navigation":
			_sign("A PATH IS A PROMISE", Vector3(0, 4, -7), CORAL, 42)
			_build_navigation()
		"materials":
			_sign("PAINT FIRST. LIGHT SECOND.", Vector3(0, 4.5, -7), MINT, 38)
			for i: int in range(3):
				var material: ShaderMaterial = ShaderMaterial.new()
				material.shader = SURFACE
				material.set_shader_parameter("atlas", _texture())
				material.set_shader_parameter("tint", [MINT, GOLD, CORAL][i])
				material.set_shader_parameter("authored_only", i == 0)
				material.set_shader_parameter("vertex_strength", 0.0 if i == 2 else 1.0)
				sample_materials.append(material)
				var mesh: MeshInstance3D = MeshInstance3D.new()
				mesh.mesh = _painted_mesh()
				mesh.material_override = material
				mesh.position = Vector3(-5 + i * 5, 0, -2)
				room.add_child(mesh)
				_box(Vector3(-5 + i * 5, 0.15, -2), Vector3(3.4, 0.3, 3.4), INK, true)
				sample_labels.append(_sign(["ACTIVE: AUTHORED", "MATTE LIT", "NO VERTEX SHADE"][i],
					Vector3(-5 + i * 5, 3.7, -2), [MINT, GOLD, CORAL][i], 26))
		"audio":
			_sign("FOLLOW THE SIGNAL", Vector3(0, 4, -7), GOLD, 46)
			_box(Vector3(-5, 1, -2), Vector3(1.8, 2, 1.8), GOLD, true)
			for z: float in [-2.6, -2.0, -1.4]:
				_box(Vector3(-5, 1.8, z), Vector3(1.5, 0.12, 0.12), INK)
			audio = AudioStreamPlayer3D.new()
			audio.stream = _tone()
			audio.max_distance = 22
			audio.unit_size = 4
			audio.volume_db = -14
			audio.position = Vector3(-5, 1.7, -2)
			room.add_child(audio)
			_sign("ORIGINAL SYNTH / 220 Hz", Vector3(-5, 3, -2), GOLD, 28)
		"persistence":
			_sign("LEAVE A TRACE", Vector3(0, 4, -7), MINT, 48)
			for i: int in range(6):
				_box(Vector3(-5 + i * 2, 1.5, -2), Vector3(1.2, 3, 1.2), INK, true)
				_box(Vector3(-5 + i * 2, 3.1, -2), Vector3(1.4, 0.2, 1.4), MINT)
				_sign("%02d" % (i + 1), Vector3(-5 + i * 2, 2, -1.35), GOLD, 36)


func _clear() -> void:
	if room != null:
		remove_child(room)
		room.queue_free()
	room = Node3D.new()
	add_child(room)
	bodies.clear()
	sample_materials.clear()
	sample_labels.clear()
	audio = null
	audio_on = false
	nav_agent = null
	nav_actor = null
	nav_go = false
	nav_arrived = false
	nav_path_peak = 0
	material_mode = 0


func _floor(at: Vector3, size: Vector3) -> void:
	_box(at - Vector3(0, size.y / 2, 0), size, STONE, true)
	_box(at - Vector3(0, 0.85, 0), Vector3(size.x + 0.4, 0.7, size.z + 0.4), INK)
	for i: int in range(16):
		_box(Vector3(-11 + (i % 8) * 3, 0.01, -6 + (i / 8) * 12),
			Vector3(1.6, 0.03, 0.08), Color("638580"))


func _mat(color: Color, unlit: bool = false) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	if unlit:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material


func _box(at: Vector3, size: Vector3, color: Color, solid: bool = false) -> MeshInstance3D:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = _mat(color)
	mesh.position = at
	room.add_child(mesh)
	if solid:
		var body: StaticBody3D = StaticBody3D.new()
		var collision: CollisionShape3D = CollisionShape3D.new()
		var shape: BoxShape3D = BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		body.add_child(collision)
		mesh.add_child(body)
	return mesh


func _sign(text: String, at: Vector3, color: Color, size: int) -> Label3D:
	var label: Label3D = Label3D.new()
	label.text = text
	label.position = at
	label.font_size = size
	label.pixel_size = 0.025
	label.modulate = color
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = false
	label.outline_size = 8
	room.add_child(label)
	return label


func _spawn_body(at: Vector3) -> RigidBody3D:
	var body: RigidBody3D = RigidBody3D.new()
	body.position = at
	body.mass = 1.5
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3.ONE
	collision.shape = shape
	body.add_child(collision)
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3.ONE
	mesh.mesh = box
	mesh.material_override = _mat(GOLD if bodies.size() % 2 == 0 else CORAL)
	body.add_child(mesh)
	room.add_child(body)
	bodies.append(body)
	return body


func launch_body() -> RigidBody3D:
	var body: RigidBody3D = _spawn_body(Vector3(-5, 4, -2))
	body.apply_central_impulse(Vector3(6, 5, 0))
	return body


func cycle_material() -> void:
	material_mode = (material_mode + 1) % 3
	var material: ShaderMaterial = sample_materials[0]
	material.set_shader_parameter("authored_only", material_mode == 0)
	material.set_shader_parameter("vertex_strength", 0.0 if material_mode == 2 else 1.0)
	sample_labels[0].text = "ACTIVE: " + ["AUTHORED", "MATTE LIT", "VERTEX BYPASS"][material_mode]


func _texture() -> ImageTexture:
	var image: Image = Image.create(32, 32, false, Image.FORMAT_RGB8)
	var ramp: Array[Color] = [Color("739a92"), Color("97b3a2"), Color("bad0af"), Color("4b7377")]
	for y: int in range(32):
		for x: int in range(32):
			var shade: int = 1
			if y % 8 == 0 or (x + (8 if (y / 8) % 2 == 0 else 0)) % 16 == 0:
				shade = 3
			elif y % 8 == 1:
				shade = 2
			image.set_pixel(x, y, ramp[shade])
	return ImageTexture.create_from_image(image)


func _painted_mesh() -> ArrayMesh:
	var tool: SurfaceTool = SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(2.5, 3, 2.5)
	var arrays: Array = mesh.get_mesh_arrays()
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	for index: int in indices:
		var vertex: Vector3 = vertices[index] + Vector3(0, 1.7, 0)
		var shade: float = 0.45 + (vertex.y / 3.2) * 0.55
		tool.set_color(Color(shade * 0.86, shade, shade * 1.05))
		tool.set_normal(normals[index])
		tool.set_uv(uvs[index] * 2)
		tool.add_vertex(vertex)
	return tool.commit()


func _build_navigation() -> void:
	# An authored navmesh with a hole, matching the visible collision obstacle.
	var navmesh: NavigationMesh = NavigationMesh.new()
	navmesh.vertices = PackedVector3Array([
		Vector3(-9, 0, -7), Vector3(-2.3, 0, -7), Vector3(2.3, 0, -7), Vector3(9, 0, -7),
		Vector3(-9, 0, -2.3), Vector3(-2.3, 0, -2.3), Vector3(2.3, 0, -2.3), Vector3(9, 0, -2.3),
		Vector3(-9, 0, 2.3), Vector3(-2.3, 0, 2.3), Vector3(2.3, 0, 2.3), Vector3(9, 0, 2.3),
		Vector3(-9, 0, 7), Vector3(-2.3, 0, 7), Vector3(2.3, 0, 7), Vector3(9, 0, 7)])
	for polygon: PackedInt32Array in [PackedInt32Array([0, 4, 5, 1]),
		PackedInt32Array([1, 5, 6, 2]), PackedInt32Array([2, 6, 7, 3]),
		PackedInt32Array([4, 8, 9, 5]), PackedInt32Array([6, 10, 11, 7]),
		PackedInt32Array([8, 12, 13, 9]), PackedInt32Array([9, 13, 14, 10]),
		PackedInt32Array([10, 14, 15, 11])]:
		navmesh.add_polygon(polygon)
	var region: NavigationRegion3D = NavigationRegion3D.new()
	region.navigation_mesh = navmesh
	room.add_child(region)
	_box(Vector3(0, 1.5, 0), Vector3(3, 3, 3), INK, true)
	_box(Vector3(0, 3.1, 0), Vector3(3.2, 0.2, 3.2), CORAL)
	nav_actor = CharacterBody3D.new()
	nav_actor.position = Vector3(-7, 0.4, 0)
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.45
	sphere.height = 0.9
	mesh.mesh = sphere
	mesh.material_override = _mat(MINT, true)
	nav_actor.add_child(mesh)
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: SphereShape3D = SphereShape3D.new()
	shape.radius = 0.4
	collision.shape = shape
	nav_actor.add_child(collision)
	room.add_child(nav_actor)
	nav_agent = NavigationAgent3D.new()
	nav_agent.path_desired_distance = 0.65
	nav_agent.target_desired_distance = 0.5
	nav_actor.add_child(nav_agent)
	_box(Vector3(7, 0.1, 0), Vector3(1.5, 0.2, 1.5), GOLD)
	_sign("DESTINATION", Vector3(7, 2, 0), GOLD, 28)


func start_navigation() -> void:
	nav_actor.position = Vector3(-7, 0.4, 0)
	nav_actor.velocity = Vector3.ZERO
	nav_agent.target_position = Vector3(7, 0, 0)
	nav_go = true
	nav_arrived = false


func toggle_audio() -> void:
	audio_on = not audio_on
	if audio_on:
		audio.play()
	else:
		audio.stop()


func _tone() -> AudioStreamWAV:
	# Precompute one seamless second so tone stability is independent of render load.
	var sample_rate: int = 22050
	var samples: PackedByteArray = PackedByteArray()
	samples.resize(sample_rate * 2)
	for i: int in range(sample_rate):
		var sample: float = sin(float(i) * TAU * 220.0 / float(sample_rate)) * 0.2
		samples.encode_s16(i * 2, int(sample * 32767))
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = samples
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_rate
	return stream


func _physics_process(delta: float) -> void:
	clock += delta
	if nav_go and nav_agent != null:
		if nav_agent.is_navigation_finished():
			nav_arrived = nav_actor.position.distance_to(Vector3(7, 0.4, 0)) < 1
			nav_go = false
		else:
			var next: Vector3 = nav_agent.get_next_path_position()
			nav_path_peak = maxi(nav_path_peak, nav_agent.get_current_navigation_path().size())
			var direction: Vector3 = next - nav_actor.position
			direction.y = 0
			nav_actor.velocity = direction.normalized() * 4
			nav_actor.move_and_slide()
