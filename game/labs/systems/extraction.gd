extends Node3D
## Standalone host: no museum, store, player or automation bus dependency.
@export var lab_id: String = "LAB-007"
const Module = preload("res://labs/modules/system_labs.gd")
var lab: Node3D
var receipt: Label

func _ready() -> void:
	lab = Module.new()
	lab.lab_id = lab_id
	add_child(lab)
	lab.setup({"automation": true})
	var camera := Camera3D.new()
	camera.position = Vector3(7, 8, 11)
	add_child(camera)
	camera.look_at(Vector3(0, 1, -2))
	camera.current = true
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -30, 0)
	add_child(light)
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(16, 16)
	scroll.size = Vector2(420, 660)
	canvas.add_child(scroll)
	var panel := VBoxContainer.new()
	panel.custom_minimum_size.x = 400
	scroll.add_child(panel)
	lab.create_controls(panel)
	var reset := Button.new()
	reset.text = "Reset owned fixture"
	reset.pressed.connect(func() -> void: lab.reset())
	panel.add_child(reset)
	receipt = Label.new()
	receipt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(receipt)
	lab.request_operation.connect(_operate)

func _operate(name: String, args: Dictionary) -> void:
	receipt.text = JSON.stringify(lab.apply_operation(name, args))

func _exit_tree() -> void:
	if is_instance_valid(lab): lab.teardown()
