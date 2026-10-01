extends Node3D

signal request_operation(operation: String, arguments: Dictionary)

const INK: Color = Color("162e40")
const STONE: Color = Color("527875")
const MINT: Color = Color("75dfb8")
const GOLD: Color = Color("e9b75b")
const CORAL: Color = Color("ed8064")

var lab_context: Dictionary = {}
var module_revision: int = 0
var _controls: Array[Node] = []


func setup(context: Dictionary) -> void:
	lab_context = context
	module_revision = 0
	box(Vector3(0, -0.25, 0), Vector3(24, 0.5, 20), STONE, true)
	box(Vector3(0, -0.85, 0), Vector3(24.4, 0.7, 20.4), INK)
	for x: int in [-12, 12]:
		box(Vector3(x, 1, 0), Vector3(0.5, 2, 20), INK, true)
	box(Vector3(0, 1, -10), Vector3(24, 2, 0.5), INK, true)
	box(Vector3(0, 1, 10), Vector3(24, 2, 0.5), INK, true)


func describe() -> Dictionary:
	return {"id": "", "title": "Lab module", "description": "No interaction registered.",
		"action": "INSPECT", "ready": false, "limits": "Module contract only."}


func operations() -> Array[Dictionary]:
	return []


func apply_operation(_operation: String, _arguments: Dictionary) -> Dictionary:
	return {"ok": false, "code": "UNKNOWN_OPERATION"}


func primary_operation() -> Dictionary:
	return {"operation": "", "arguments": {}}


func observe() -> Dictionary:
	return {"revision": module_revision}


func reset() -> Dictionary:
	return {"ok": false, "code": "RESET_NOT_IMPLEMENTED"}


func teardown() -> void:
	for control: Node in _controls:
		if is_instance_valid(control):
			control.queue_free()
	_controls.clear()


func scenario() -> Array[Dictionary]:
	return []


func create_controls(_parent: Control) -> void:
	pass


func box(at: Vector3, size: Vector3, color: Color, solid: bool = false) -> MeshInstance3D:
	var visual: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	visual.position = at
	visual.material_override = material(color)
	add_child(visual)
	if solid:
		var body: StaticBody3D = StaticBody3D.new()
		var shape: CollisionShape3D = CollisionShape3D.new()
		var collider: BoxShape3D = BoxShape3D.new()
		collider.size = size
		shape.shape = collider
		body.add_child(shape)
		visual.add_child(body)
	return visual


func material(color: Color, unlit: bool = false) -> StandardMaterial3D:
	var result: StandardMaterial3D = StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 0.9
	if unlit:
		result.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return result


func sign(text: String, at: Vector3, color: Color = GOLD, font_size: int = 28) -> Label3D:
	var label: Label3D = Label3D.new()
	label.text = text
	label.position = at
	label.font_size = font_size
	label.pixel_size = 0.008
	label.modulate = color
	label.outline_size = 4
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)
	return label


func control_button(parent: Control, label: String, operation: String, arguments: Dictionary) -> Button:
	var button: Button = Button.new()
	button.text = label
	button.pressed.connect(func() -> void: request_operation.emit(operation, arguments.duplicate(true)))
	parent.add_child(button)
	_controls.append(button)
	return button
