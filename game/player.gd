extends CharacterBody3D

const SPEED: float = 6.0
const JUMP: float = 7.0
var jumps: int = 0
var distance: float = 0.0
var start_position: Vector3 = Vector3.ZERO
var enabled: bool = true
var visual: Node3D
var reduced_motion: bool = false
var clock: float = 0.0


func _ready() -> void:
	start_position = position
	var shape: CollisionShape3D = CollisionShape3D.new()
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	visual = Node3D.new()
	add_child(visual)
	_piece(Vector3(0, 0.83, 0), Vector3(0.54, 0.64, 0.34), Color("e8dec5"))
	_piece(Vector3(0, 1.34, 0), Vector3(0.5, 0.43, 0.43), Color("ffc58a"))
	_piece(Vector3(0, 1.58, 0), Vector3(0.58, 0.2, 0.47), Color("6ce2c6"))
	_piece(Vector3(0, 1.06, -0.22), Vector3(0.64, 0.15, 0.14), Color("ed795c"))
	_piece(Vector3(-0.17, 0.3, 0), Vector3(0.22, 0.5, 0.3), Color("243a52"))
	_piece(Vector3(0.17, 0.3, 0), Vector3(0.22, 0.5, 0.3), Color("243a52"))
	_piece(Vector3(-0.14, 1.38, -0.225), Vector3(0.07, 0.07, 0.02), Color("142538"))
	_piece(Vector3(0.14, 1.38, -0.225), Vector3(0.07, 0.07, 0.02), Color("142538"))
	_piece(Vector3(0, 1.05, 0.3), Vector3(0.35, 0.5, 0.2), Color("b29454"))
	var shadow: MeshInstance3D = MeshInstance3D.new()
	var disk: CylinderMesh = CylinderMesh.new()
	disk.top_radius = 0.42
	disk.bottom_radius = 0.42
	disk.height = 0.015
	disk.radial_segments = 12
	shadow.mesh = disk
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color("152d39")
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shadow.material_override = mat
	shadow.position.y = 0.015
	add_child(shadow)


func _piece(at: Vector3, size: Vector3, color: Color) -> void:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.position = at
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	mesh.material_override = material
	visual.add_child(mesh)


func _physics_process(delta: float) -> void:
	clock += delta
	if not enabled:
		velocity.x = 0
		velocity.z = 0
	else:
		var axis: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		# Screen-relative axes for the fixed isometric camera.
		var direction: Vector3 = Vector3(axis.x + axis.y, 0, axis.y - axis.x).normalized()
		velocity.x = direction.x * SPEED * axis.length()
		velocity.z = direction.z * SPEED * axis.length()
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP
			jumps += 1
		if direction.length_squared() > 0.01:
			visual.rotation.y = atan2(-direction.x, -direction.z)
		visual.position.y = 0 if reduced_motion else sin(clock * 13) * axis.length() * 0.035
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	var previous: Vector3 = position
	move_and_slide()
	distance += Vector2(position.x - previous.x, position.z - previous.z).length()
	if position.y < -8:
		teleport(start_position)


func teleport(at: Vector3) -> void:
	position = at
	velocity = Vector3.ZERO
