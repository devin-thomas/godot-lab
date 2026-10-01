extends Node3D

const PlayerScript: GDScript = preload("res://player.gd")
const WorldScript: GDScript = preload("res://world.gd")
const StoreScript: GDScript = preload("res://lab_store.gd")
const Operation: GDScript = preload("res://addons/cappy/cappy_operation.gd")
const RegistryScript: GDScript = preload("res://labs/lab_registry.gd")
const BusScript: GDScript = preload("res://domain/operation_bus.gd")
const IDS: Array[String] = ["motion", "physics", "navigation", "materials", "audio", "persistence"]
const TITLES: Array[String] = ["Motion atelier", "Gravity foundry", "Pathfinder garden",
	"Paint & light", "Signal chamber", "Memory archive"]
const DESCRIPTIONS: Array[String] = [
	"Feel a CharacterBody3D slide, jump and land against real collision shapes.\n\nWalk across the floor and jump. The ochre stairs are solid; the coral block stops you.",
	"These are RigidBody3D objects, not animated props. Gravity, contact and impulses determine their motion.\n\nLaunch a cube and watch it settle. Walk into the stack to nudge it.",
	"A NavigationAgent3D follows an authored NavigationMesh around a solid obstacle.\n\nDispatch the mint courier. Its route must go around the tower to reach the gold pad.",
	"One original 32 x 32 texture. Nearest sampling. Vertex colors shape broad shadows.\n\nCycle authored shade, matte lighting and vertex-color bypass. Compare what each contributes.",
	"An AudioStreamPlayer3D emits an original synthesized 220 Hz tone. The listener follows you.\n\nStart the signal, then walk near and far. Distance changes its level; lateral position changes its pan.",
	"FileAccess writes versioned JSON to this game's own user directory. Progress survives a restart.\n\nWrite a checkpoint, reload it from disk, and inspect the receipt. Other applications' data is untouched."]
const ACTIONS: Array[String] = ["JUMP", "LAUNCH CUBE", "DISPATCH COURIER", "CYCLE MATERIAL", "START / STOP SIGNAL", "SAVE & RELOAD"]

var player: CharacterBody3D
var world: Node3D
var store: RefCounted
var camera: Camera3D
var current: String = "hub"
var ui_title: Label
var ui_copy: Label
var ui_status: Label
var ui_hint: Label
var ui_receipt: Label
var action_button: Button
var return_button: Button
var lab_buttons: Array[Button] = []
var crt: ColorRect
var progress_label: Label
var action_count: int = 0
var tick: int = 0
var motion_origin: float = 0
var motion_jumps: int = 0
var launched: RigidBody3D
var launched_ticks: int = 0
var automation: bool = false
var running_scenario: bool = false
var record_op: RefCounted
var replay_op: RefCounted
var record_start_tick: int = 0
var record_commands: Array[Dictionary] = []
var replay_commands: Array = []
var replay_duration: int = 0
var replay_start_tick: int = 0
var replay_cursor: int = 0
var replay_action_origin: int = 0
var replay_expected: Dictionary = {}
var args: PackedStringArray
var registry: RefCounted
var operation_bus: RefCounted
var active_module: Node3D
var module_controls: VBoxContainer
var module_workbench: PanelContainer
var catalog_popup: PopupPanel
var catalog_rows: VBoxContainer
var catalog_search: LineEdit
var inspector_popup: PopupPanel
var inspector_text: TextEdit
var operation_serial: int = 0
var last_receipt: Dictionary = {}
var live_api: Node


func _ready() -> void:
	args = OS.get_cmdline_user_args()
	automation = args.has("--automation") or args.has("--verify") or args.has("--tour") or args.has("--inspect-save") or args.has("--module-verify")
	DisplayServer.window_set_title("Godot Lab | Signal Observatory")
	_setup_input()
	store = StoreScript.new()
	if automation or not OS.get_environment("CAPPY_ENDPOINT").is_empty():
		store.path = "user://godot-lab/automation-progress.json"
	var load_result: Error = store.load_progress()
	_setup_environment()
	world = WorldScript.new()
	add_child(world)
	world.build_hub()
	player = PlayerScript.new()
	player.position = Vector3(0, 0.2, 2)
	add_child(player)
	player.reduced_motion = store.reduced_motion
	var listener: AudioListener3D = AudioListener3D.new()
	player.add_child(listener)
	listener.make_current()
	_setup_camera()
	registry = RegistryScript.new()
	if not registry.load_catalog():
		push_error(registry.error)
		get_tree().quit(1)
		return
	operation_bus = BusScript.new()
	_register_host_operations()
	_build_ui()
	_set_hub_text()
	if load_result != OK:
		ui_receipt.text = store.last_error + "\nRepair requires an explicit checkpoint save."
	_register_cappy()
	_setup_live_api()
	if args.has("--inspect-save"):
		_inspect_save.call_deferred()
	elif args.has("--verify"):
		_run_verification.call_deferred()
	elif args.has("--tour"):
		_run_tour.call_deferred()
	elif args.has("--module-verify"):
		_run_module_verification.call_deferred()


func _setup_input() -> void:
	var keys: Dictionary = {"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN],
		"jump": [KEY_SPACE], "interact": [KEY_E], "reset_lab": [KEY_R], "back": [KEY_ESCAPE]}
	for action: String in keys:
		InputMap.add_action(action)
		for key: int in keys[action]:
			var event: InputEventKey = InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
	var buttons: Dictionary = {"jump": JOY_BUTTON_A, "interact": JOY_BUTTON_X,
		"back": JOY_BUTTON_B, "reset_lab": JOY_BUTTON_Y}
	for action: String in buttons:
		var event: InputEventJoypadButton = InputEventJoypadButton.new()
		event.button_index = buttons[action]
		InputMap.action_add_event(action, event)
	for action: String in ["move_left", "move_right", "move_up", "move_down"]:
		var event: InputEventJoypadMotion = InputEventJoypadMotion.new()
		event.axis = JOY_AXIS_LEFT_X if action in ["move_left", "move_right"] else JOY_AXIS_LEFT_Y
		event.axis_value = -1 if action in ["move_left", "move_up"] else 1
		InputMap.action_add_event(action, event)


func _setup_environment() -> void:
	var environment: WorldEnvironment = WorldEnvironment.new()
	var settings: Environment = Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("122d3b")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("86b3ba")
	settings.ambient_light_energy = 0.65
	settings.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	environment.environment = settings
	add_child(environment)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -25, 0)
	sun.light_color = Color("ffe3b0")
	sun.light_energy = 1.2
	add_child(sun)


func _setup_camera() -> void:
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 30
	camera.h_offset = 3.0
	camera.position = Vector3(21, 24, 23)
	add_child(camera)
	camera.look_at(Vector3(0, 0, -2))
	camera.current = true


func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	var root: Control = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	var theme: Theme = Theme.new()
	var font: SystemFont = SystemFont.new()
	font.font_names = PackedStringArray(["Consolas", "DejaVu Sans Mono", "Courier New"])
	theme.default_font = font
	theme.default_font_size = 15
	for name: String in ["normal", "hover", "pressed", "focus"]:
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color("203e4c") if name == "normal" else Color("496857")
		style.border_color = Color("608d82") if name == "normal" else Color("edbd68")
		style.set_border_width_all(2)
		style.content_margin_left = 12
		style.content_margin_right = 12
		style.content_margin_top = 9
		style.content_margin_bottom = 9
		theme.set_stylebox(name, "Button", style)
	theme.set_color("font_color", "Button", Color("f2e3c6"))
	root.theme = theme
	var header: PanelContainer = _panel(root, Vector2(24, 20), Vector2(850, 76))
	var row: HBoxContainer = HBoxContainer.new()
	header.add_child(row)
	var title: Label = _label("GODOT LAB", 28, Color("edbd68"))
	title.custom_minimum_size.x = 235
	row.add_child(title)
	row.add_child(_label("SIGNAL OBSERVATORY\nWalk in. Try it. Inspect the mechanism.", 16, Color("d8e3cf")))
	var side: PanelContainer = _panel(root, Vector2(-370, 116), Vector2(346, 475))
	side.set_anchor(SIDE_LEFT, 1)
	side.set_anchor(SIDE_RIGHT, 1)
	side.offset_left = -370
	side.offset_right = -24
	side.offset_top = 116
	side.offset_bottom = 591
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 13)
	side.add_child(column)
	ui_title = _label("", 23, Color("edbd68"))
	column.add_child(ui_title)
	ui_copy = _label("", 15, Color("d8e3cf"))
	ui_copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_copy.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(ui_copy)
	ui_status = _label("", 14, Color("75dfb8"))
	ui_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(ui_status)
	var controls_scroll: ScrollContainer = ScrollContainer.new()
	module_workbench = _panel(root, Vector2(24, 245), Vector2(420, 340))
	module_workbench.add_child(controls_scroll)
	module_controls = VBoxContainer.new()
	module_controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls_scroll.add_child(module_controls)
	module_workbench.visible = false
	action_button = _button("", column, func() -> void: command("activate"))
	return_button = _button("RETURN TO OBSERVATORY   [Esc]", column, func() -> void: command("hub"))
	ui_receipt = _label("", 13, Color("e9b75b"))
	ui_receipt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(ui_receipt)
	var bottom: PanelContainer = _panel(root, Vector2(24, -112), Vector2(1232, 92))
	bottom.set_anchor(SIDE_TOP, 1)
	bottom.set_anchor(SIDE_BOTTOM, 1)
	bottom.set_anchor(SIDE_RIGHT, 1)
	bottom.offset_left = 24
	bottom.offset_right = -24
	bottom.offset_top = -112
	bottom.offset_bottom = -20
	var bottom_col: VBoxContainer = VBoxContainer.new()
	bottom.add_child(bottom_col)
	var tabs: HBoxContainer = HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	bottom_col.add_child(tabs)
	for i: int in range(6):
		var id: String = IDS[i]
		var button: Button = _button("%d %s" % [i + 1, id.to_upper()], tabs,
			func() -> void: command("enter", id))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lab_buttons.append(button)
	ui_hint = _label("", 14, Color("d8e3cf"))
	bottom_col.add_child(ui_hint)
	var comfort: PanelContainer = _panel(root, Vector2(-370, 20), Vector2(346, 76))
	comfort.set_anchor(SIDE_LEFT, 1)
	comfort.set_anchor(SIDE_RIGHT, 1)
	comfort.offset_left = -370
	comfort.offset_right = -24
	comfort.offset_top = 20
	comfort.offset_bottom = 96
	var options: HBoxContainer = HBoxContainer.new()
	comfort.add_child(options)
	var calm: CheckButton = CheckButton.new()
	calm.text = "CALM"
	calm.button_pressed = store.reduced_motion
	calm.toggled.connect(func(value: bool) -> void:
		store.reduced_motion = value
		player.reduced_motion = value
		_save_settings())
	options.add_child(calm)
	var mute: CheckButton = CheckButton.new()
	mute.text = "MUTE"
	mute.button_pressed = store.muted
	mute.toggled.connect(func(value: bool) -> void:
		store.muted = value
		AudioServer.set_bus_mute(0, value)
		_save_settings())
	options.add_child(mute)
	AudioServer.set_bus_mute(0, store.muted)
	var retro: CheckButton = CheckButton.new()
	retro.text = "CRT"
	retro.toggled.connect(func(value: bool) -> void: crt.visible = value)
	options.add_child(retro)
	progress_label = _label("", 16, Color("75dfb8"))
	progress_label.position = Vector2(32, 105)
	root.add_child(progress_label)
	crt = ColorRect.new()
	crt.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	crt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader: ShaderMaterial = ShaderMaterial.new()
	shader.shader = preload("res://art/scanlines.gdshader")
	crt.material = shader
	crt.visible = false
	root.add_child(crt)
	var catalog_button: Button = _button("CATALOG / 96 LABS", root,
		func() -> void: _open_catalog())
	catalog_button.position = Vector2(24, 142)
	var inspect_button: Button = _button("INSPECT STATE", root,
		func() -> void: _open_inspector())
	inspect_button.position = Vector2(24, 185)
	_build_catalog()
	_refresh_progress()


func _panel(root: Control, at: Vector2, size: Vector2) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.position = at
	panel.size = size
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.12, 0.16, 0.96)
	style.border_color = Color("537d78")
	style.set_border_width_all(2)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)
	root.add_child(panel)
	return panel


func _label(text: String, size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _button(text: String, parent: Control, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _save_settings() -> void:
	if store.save_progress() != OK:
		ui_receipt.text = store.last_error


func _set_hub_text() -> void:
	ui_title.text = "THE OBSERVATORY"
	ui_copy.text = "Explore the 96-lab capability atlas.\n\nThe six doors lead to the original rooms. Open CATALOG for additional playable prototypes and the complete design program.\n\nTry a mechanism, change its parameters, and inspect its actual state."
	action_button.text = "ENTER NEAREST DOOR   [E]"
	return_button.visible = false
	ui_status.text = "Keyboard + pointer + controller paths"
	ui_hint.text = "WASD / arrows: move    Space: jump    E: interact    1-6: labs    Esc: hub"
	ui_receipt.text = "Automatic proof is recorded separately from human playtesting."


func command(kind: String, value: String = "", remember: bool = true) -> void:
	if kind == "enter" and registry.module_ids().has(value) and record_op != null:
		ui_receipt.text = "Input-v1 recording covers the original rooms. Use this prototype's named Cappy scenario."
		return
	if remember and record_op != null:
		record_commands.append({"tick": tick - record_start_tick, "kind": kind, "value": value})
	if remember and kind in ["enter", "hub", "reset"]:
		var name: String = {"enter": "host.enter", "hub": "host.hub", "reset": "host.reset"}[kind]
		_request_operation(name, {"id": value} if kind == "enter" else {})
		return
	match kind:
		"enter":
			if registry.module_ids().has(value):
				_enter_module(value)
				return
			if not IDS.has(value):
				push_error("Unknown lab: " + value)
				return
			_leave_module()
			current = value
			camera.size = 24
			world.build_lab(value)
			player.teleport(Vector3(0, 0.2, 6))
			motion_origin = player.distance
			motion_jumps = player.jumps
			launched = null
			var index: int = IDS.find(value)
			ui_title.text = "%02d / %s" % [index + 1, TITLES[index].to_upper()]
			ui_copy.text = DESCRIPTIONS[index]
			action_button.text = ACTIONS[index] + "   [E]"
			return_button.visible = true
			ui_hint.text = "WASD / arrows: move    Space: jump    E: action    R: reset room    Esc: hub"
			ui_receipt.text = "Try the mechanism. Watch its state change."
		"hub":
			_leave_module()
			current = "hub"
			camera.size = 30
			launched = null
			world.build_hub()
			player.teleport(Vector3(0, 0.2, 2))
			_set_hub_text()
		"reset":
			if active_module != null:
				last_receipt = active_module.reset()
				operation_bus.reset_epoch()
				_release_inputs()
				ui_receipt.text = JSON.stringify(last_receipt)
			elif current != "hub":
				command("enter", current, false)
		"activate":
			action_count += 1
			_activate()
		"press":
			Input.action_press(value)
		"release":
			Input.action_release(value)
		_:
			push_error("Unknown command: " + kind)


func _activate() -> void:
	if active_module != null:
		var primary: Dictionary = active_module.primary_operation()
		_request_operation(primary["operation"], primary["arguments"])
		return
	match current:
		"hub":
			var nearest: int = -1
			var best: float = 3.1
			for i: int in range(world.portals.size()):
				var distance: float = player.position.distance_to(world.portals[i])
				if distance < best:
					nearest = i
					best = distance
			if nearest >= 0:
				command("enter", IDS[nearest])
			else:
				ui_receipt.text = "Move closer to a doorway, or choose a numbered lab."
		"motion":
			command("press", "jump")
			_release_jump.call_deferred()
		"physics":
			if world.bodies.size() >= 24:
				ui_receipt.text = "24-body budget reached. Press R to reset this room."
				return
			launched = world.launch_body()
			launched_ticks = tick
			ui_receipt.text = "Impulse (6, 5, 0) applied to a 1.5 kg cube."
		"navigation":
			world.start_navigation()
			ui_receipt.text = "Courier dispatched. Waiting for actual arrival."
		"materials":
			world.cycle_material()
			ui_receipt.text = "Shader mode: " + ["AUTHORED", "MATTE LIT", "VERTEX BYPASS"][world.material_mode]
			_complete("materials")
		"audio":
			world.toggle_audio()
			ui_receipt.text = "Signal running. Walk to test attenuation." if world.audio_on else "Signal stopped."
			if world.audio_on:
				_complete("audio")
		"persistence":
			# This explicit action may repair this game's malformed demo save.
			store.last_error = ""
			if store.complete_lab("persistence") != OK:
				ui_receipt.text = store.last_error
				return
			var reader: RefCounted = StoreScript.new()
			reader.path = store.path
			if reader.load_progress() != OK or not reader.completed.has("persistence"):
				ui_receipt.text = "Reload failed: " + reader.last_error
				return
			ui_receipt.text = "Committed schema 1.\nFresh reader verified %d saved lab seals." % reader.completed.size()
			_refresh_progress()


func _release_jump() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	command("release", "jump")


func _complete(id: String) -> void:
	if store.completed.has(id):
		return
	if store.complete_lab(id) != OK:
		ui_receipt.text = store.last_error
		return
	_refresh_progress()


func _refresh_progress() -> void:
	progress_label.text = "%02d / 06 LAB SEALS   |   LOCAL PROGRESS" % store.completed.size()
	for i: int in range(6):
		lab_buttons[i].text = "%d %s%s" % [i + 1, IDS[i].to_upper(), " +" if store.completed.has(IDS[i]) else ""]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		command("hub")
	elif event.is_action_pressed("interact"):
		command("activate")
	elif event.is_action_pressed("reset_lab"):
		command("reset")
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode >= KEY_1 and event.physical_keycode <= KEY_6:
			command("enter", IDS[event.physical_keycode - KEY_1])
	if record_op != null:
		for action: String in ["move_left", "move_right", "move_up", "move_down", "jump"]:
			if event.is_action_pressed(action):
				record_commands.append({"tick": tick - record_start_tick, "kind": "press", "value": action})
			elif event.is_action_released(action):
				record_commands.append({"tick": tick - record_start_tick, "kind": "release", "value": action})


func _physics_process(_delta: float) -> void:
	tick += 1
	operation_bus.advance_tick(tick)
	if active_module != null:
		var state: Dictionary = active_module.observe()
		ui_status.text = JSON.stringify(state).left(220)
	if current == "motion" and player.distance - motion_origin > 2 and player.jumps > motion_jumps:
		_complete("motion")
	if current == "physics" and is_instance_valid(launched) and tick - launched_ticks > 120:
		if launched.position.y < 2 and launched.linear_velocity.length() < 0.3:
			_complete("physics")
	if current == "navigation" and world.nav_arrived:
		_complete("navigation")
	if current == "hub":
		ui_status.text = "Walk to a door or choose a lab.\nSeals record demonstrated interactions."
	else:
		match current:
			"motion": ui_status.text = "Travel %.1f m  |  jumps %d\nNeed 2 m and a jump for the seal." % [player.distance - motion_origin, player.jumps - motion_jumps]
			"physics": ui_status.text = "%d real bodies  |  gravity 9.8 m/s2\nSeal when launched cube settles." % world.bodies.size()
			"navigation": ui_status.text = "Path points %d  |  arrived %s" % [world.nav_path_peak, world.nav_arrived]
			"materials": ui_status.text = "32 x 32 / 4-color original texture\nNearest filter / matte / vertex color"
			"audio": ui_status.text = "Listener distance %.1f m\n%s" % [player.position.distance_to(world.audio.position), "MUTED in comfort settings" if store.muted else "Spatial stream running" if world.audio_on else "Signal stopped"]
			"persistence": ui_status.text = "Schema 1  |  %d persisted seals\nFileAccess + atomic rename" % store.completed.size()
	if record_op != null and automation:
		var elapsed: int = tick - record_start_tick
		match elapsed:
			30: command("activate")
			90: command("enter", "physics")
			100: command("activate")
			180: command("enter", "materials")
			190: command("activate")
	if replay_op != null:
		var elapsed: int = tick - replay_start_tick
		while replay_cursor < replay_commands.size() and replay_commands[replay_cursor]["tick"] <= elapsed:
			var item: Dictionary = replay_commands[replay_cursor]
			command(item["kind"], item["value"], false)
			replay_cursor += 1
		if elapsed >= replay_duration:
			var result: Dictionary = _semantic_state(action_count - replay_action_origin)
			if result != replay_expected:
				replay_op.fail("REPLAY_STATE_MISMATCH", JSON.stringify(result))
			else:
				replay_op.event("RUN_END", replay_duration * 1000.0 / 60.0, result)
				replay_op.complete(result)
			replay_op = null
			_release_inputs()


func _register_cappy() -> void:
	for id: String in IDS:
		Cappy.register_scenario(id, TITLES[IDS.find(id)], {},
			func(op: RefCounted) -> void:
				command("enter", id, false)
				op.mark_ready(),
			func(op: RefCounted) -> void: _capture_scenario(id, op))
	Cappy.set_replay_provider(_record_start, _record_stop, _replay_prepare, _replay_start, false)
	for id: String in registry.module_ids():
		Cappy.register_scenario(id.to_lower(), id + " / playable prototype", {},
			func(op: RefCounted) -> void:
				command("enter", id, false)
				if active_module == null:
					op.fail("MODULE_UNAVAILABLE", id)
				else:
					op.mark_ready(),
			func(op: RefCounted) -> void:
				var result: Dictionary = await module_scenario(id, 24)
				op.event("LAB_PROOF", op.elapsed_msec(), result)
				if result["passed"]:
					await wait_ticks(120)
					op.complete(result)
				else:
					op.fail("LAB_ASSERTION_FAILED", JSON.stringify(result)))


func _capture_scenario(id: String, op: RefCounted) -> void:
	running_scenario = true
	op.event("LAB_ENTER", 0, {"lab": id})
	var result: Dictionary = await scenario(id, op)
	if not result["passed"]:
		op.fail("LAB_ASSERTION_FAILED", JSON.stringify(result))
	else:
		op.event("LAB_PROOF", op.elapsed_msec(), result)
		op.complete(result)
	running_scenario = false


func _register_host_operations() -> void:
	var descriptors: Array[Dictionary] = [
		{"name": "host.enter", "scope": "host", "arguments": {"id": {"type": "enum", "values": registry.playable_ids()}}, "required": ["id"], "mutates": true},
		{"name": "host.reset", "scope": "host", "arguments": {}, "required": [], "mutates": true},
		{"name": "host.hub", "scope": "host", "arguments": {}, "required": [], "mutates": true},
		{"name": "host.observe", "scope": "host", "arguments": {}, "required": [], "mutates": false}]
	for descriptor: Dictionary in descriptors:
		var name: String = descriptor["name"]
		var result: Error = operation_bus.register_operation(descriptor,
			func(arguments: Dictionary) -> Dictionary:
				match name:
					"host.enter":
						if record_op != null and registry.module_ids().has(arguments["id"]):
							return {"ok": false, "code": "INPUT_V1_RECORDING_SCOPE", "message": "Use the prototype's named Cappy scenario; input-v1 covers original rooms."}
						command("enter", arguments["id"], false)
						return {"ok": current == arguments["id"], "code": "ENTERED" if current == arguments["id"] else "MODULE_UNAVAILABLE", "lab": current}
					"host.reset":
						if active_module != null:
							var outcome: Dictionary = active_module.reset()
							if not outcome.get("ok", false):
								return outcome
							operation_bus.reset_epoch()
							_release_inputs()
						else:
							command("reset", "", false)
					"host.hub": command("hub", "", false)
				return {"ok": true, "code": "OK", "result": inspect_state(false)})
		if result != OK:
			push_error("Cannot register host operation: %s" % name)


func _setup_live_api() -> void:
	var port_text: String = OS.get_environment("GODOT_LAB_API_PORT")
	if port_text.is_empty():
		return
	if not port_text.is_valid_int() or int(port_text) < 0 or int(port_text) > 65535:
		push_error("GODOT_LAB_API_PORT must be an integer from 0 to 65535")
		get_tree().quit(1)
		return
	var script: GDScript = load("res://automation/live_api.gd")
	if script == null or not script.can_instantiate():
		push_error("Optional live API could not load")
		get_tree().quit(1)
		return
	live_api = script.new()
	live_api.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(live_api)
	var configured: Dictionary = live_api.configure(operation_bus, inspect_state, int(port_text),
		OS.get_environment("GODOT_LAB_API_TOKEN"))
	print("LIVE_API " + JSON.stringify(configured))
	if not configured["ok"]:
		get_tree().quit(1)


func _request_operation(name: String, arguments: Dictionary) -> Dictionary:
	operation_serial += 1
	last_receipt = operation_bus.submit({"operation": name, "arguments": arguments,
		"request_id": "host-%d" % operation_serial})
	ui_receipt.text = "%s / revision %d / tick %d" % [last_receipt["code"], last_receipt["revision"], last_receipt["tick"]]
	return last_receipt


func _enter_module(id: String) -> void:
	_leave_module()
	var module: Node3D = registry.instantiate(id)
	if module == null:
		ui_receipt.text = registry.error
		return
	world.build_module_room(id)
	world.room.add_child(module)
	active_module = module
	current = id
	module.setup({"player": player, "camera": camera, "host": self, "automation": automation,
		"namespace": "automation" if automation else "player"})
	module.request_operation.connect(_request_operation)
	for descriptor: Dictionary in module.operations():
		var name: String = descriptor["name"]
		descriptor["scope"] = "active-module"
		var error: Error = operation_bus.register_operation(descriptor,
			func(arguments: Dictionary) -> Dictionary: return module.apply_operation(name, arguments))
		if error != OK:
			push_error("Module operation registration failed: %s / %s" % [name, error])
			ui_receipt.text = "OPERATION_REGISTRATION_FAILED: " + name
			return
	module.create_controls(module_controls)
	_fit_module_controls(module_controls)
	module_workbench.visible = true
	var description: Dictionary = module.describe()
	ui_title.text = "%s / %s" % [id, description["title"]]
	ui_copy.text = description["description"]
	action_button.text = description.get("action", "TRY MECHANISM") + "   [E]"
	return_button.visible = true
	ui_hint.text = "E: primary action    Controls: parameters    R: reset fixture    Esc: hub"
	ui_receipt.text = "Playable prototype. Full contract qualification is tracked separately."
	camera.size = 24
	player.teleport(Vector3(0, 0.2, 6))
	_release_inputs()


func _leave_module() -> void:
	_release_inputs()
	if active_module != null:
		active_module.teardown()
		active_module = null
	operation_bus.unregister_scope("active-module")
	operation_bus.reset_epoch()
	for child: Node in module_controls.get_children():
		module_controls.remove_child(child)
		child.queue_free()
	module_workbench.visible = false
	get_tree().paused = false
	Engine.time_scale = 1.0


func _fit_module_controls(node: Node) -> void:
	if node is Button:
		node.tooltip_text = node.text
		node.clip_text = true
		node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		node.custom_minimum_size.x = 0
		node.custom_minimum_size.y = 38
		node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for child: Node in node.get_children():
		_fit_module_controls(child)


func inspect_state(include_receipt: bool = true) -> Dictionary:
	var bus_state: Dictionary = operation_bus.observation()
	bus_state.erase("receipts")
	bus_state.erase("events")
	var state: Dictionary = {"lab": current, "tick": tick, "operation_bus": bus_state,
		"module": active_module.observe() if active_module != null else {},
		"player": {"position": {"x": player.position.x, "y": player.position.y, "z": player.position.z},
			"jumps": player.jumps},
		"operations": operation_bus.describe(), "qualification": "Prototype logic and runtime evidence are separate from device and provider acceptance."}
	if include_receipt:
		state["last_receipt"] = last_receipt.duplicate(true)
	return state


func _build_catalog() -> void:
	catalog_popup = PopupPanel.new()
	add_child(catalog_popup)
	var column: VBoxContainer = VBoxContainer.new()
	column.custom_minimum_size = Vector2(740, 490)
	catalog_popup.add_child(column)
	column.add_child(_label("CAPABILITY ATLAS / 96 LAB CONTRACTS", 23, Color("edbd68")))
	column.add_child(_label("PLAY: original room    PROTOTYPE: new mechanism    SPECIFIED: design contract", 13, Color("75dfb8")))
	catalog_search = LineEdit.new()
	catalog_search.placeholder_text = "Search title, lab number, wing or capability"
	column.add_child(catalog_search)
	catalog_search.text_changed.connect(func(_text: String) -> void: _filter_catalog())
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	catalog_rows = VBoxContainer.new()
	catalog_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(catalog_rows)
	_button("CLOSE", column, func() -> void: catalog_popup.hide())
	inspector_popup = PopupPanel.new()
	add_child(inspector_popup)
	var inspector_column: VBoxContainer = VBoxContainer.new()
	inspector_column.custom_minimum_size = Vector2(740, 490)
	inspector_popup.add_child(inspector_column)
	inspector_column.add_child(_label("LIVE STATE / TYPED OPERATIONS", 23, Color("edbd68")))
	inspector_text = TextEdit.new()
	inspector_text.editable = false
	inspector_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inspector_column.add_child(inspector_text)
	_button("REFRESH", inspector_column, func() -> void: inspector_text.text = JSON.stringify(inspect_state(), "  "))
	_button("CLOSE", inspector_column, func() -> void: inspector_popup.hide())


func _open_catalog() -> void:
	_filter_catalog()
	catalog_popup.popup_centered()
	catalog_search.grab_focus()


func _filter_catalog() -> void:
	for child: Node in catalog_rows.get_children():
		catalog_rows.remove_child(child)
		child.queue_free()
	for entry: Dictionary in registry.search(catalog_search.text):
		var id: String = entry["id"]
		var status: String = "PLAY" if registry.BASELINE.has(id) else "PROTOTYPE" if registry.available(id) else "SPECIFIED"
		var button: Button = _button("%s / %s / %s / %s" % [id, entry["title"], entry["wing"], status], catalog_rows,
			func() -> void:
				if registry.available(id):
					_request_operation("host.enter", {"id": registry.route(id)})
				else:
					ui_title.text = id + " / SPECIFIED"
					ui_copy.text = entry["payoff"] + "\n\n" + entry["limits"]
					ui_receipt.text = "This lab has a design contract; no playable module is registered yet."
				catalog_popup.hide())
		button.tooltip_text = entry["payoff"]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT


func _open_inspector() -> void:
	inspector_text.text = JSON.stringify(inspect_state(), "  ")
	inspector_popup.popup_centered()


func module_scenario(id: String, minimum_wait_ticks: int = 1) -> Dictionary:
	command("enter", id, false)
	if active_module == null or current != id:
		return {"lab": id, "passed": false, "checks": [{"name": "module-entry", "passed": false}]}
	var checks: Array[Dictionary] = []
	var executing_module: Node3D = active_module
	for step: Dictionary in executing_module.scenario():
		var receipt: Dictionary = _request_operation(step["operation"], step.get("arguments", {}))
		if step.has("poll_until_code"):
			var deadline: int = Time.get_ticks_msec() + clampi(int(step.get("timeout_msec", 1000)), 1, 10000)
			while receipt["ok"] and receipt["code"] != step["poll_until_code"] and Time.get_ticks_msec() < deadline:
				await get_tree().physics_frame
				if not is_instance_valid(executing_module) or active_module != executing_module:
					return {"lab": id, "passed": false, "code": "SCENARIO_INTERRUPTED", "checks": checks}
				receipt = _request_operation(step["operation"], step.get("arguments", {}))
		var wait_ticks: int = clampi(maxi(int(step.get("wait_ticks", 1)), minimum_wait_ticks), 1, 300)
		for frame: int in range(wait_ticks):
			await get_tree().physics_frame
			if not is_instance_valid(executing_module) or active_module != executing_module:
				return {"lab": id, "passed": false, "code": "SCENARIO_INTERRUPTED", "checks": checks}
		var passed: bool = receipt["ok"] == step.get("expect_ok", true)
		if step.has("expect_code") or step.has("expect_bus_code"):
			passed = passed and receipt["code"] == step.get("expect_bus_code", step.get("expect_code"))
		var observed: Dictionary = active_module.observe()
		for key: String in step.get("assert", {}):
			passed = passed and _matches_observation(observed.get(key), step["assert"][key])
		for key: String in step.get("assert_near", {}):
			var rule: Dictionary = step["assert_near"][key]
			passed = passed and observed.get(key) is float and absf(observed[key] - rule["value"]) <= rule["tolerance"]
		checks.append({"name": step["operation"], "passed": passed, "receipt": receipt, "observed": observed})
	var all_passed: bool = not checks.is_empty()
	for check: Dictionary in checks:
		all_passed = all_passed and check["passed"]
	return {"lab": id, "passed": all_passed, "checks": checks}


func _matches_observation(actual: Variant, expected: Variant) -> bool:
	if expected is Dictionary:
		if not actual is Dictionary:
			return false
		for key: Variant in expected:
			if not actual.has(key) or not _matches_observation(actual[key], expected[key]):
				return false
		return true
	return actual == expected


func _operation_effects_observation() -> Dictionary:
	var observed: Dictionary = active_module.observe().duplicate(true)
	# A worker keeps progressing during a retry; job identity, revision and commits must stay fixed.
	if current == "LAB-028":
		observed.erase("worker_progress")
		observed.erase("worker_active")
	return observed


func _run_module_verification() -> void:
	var results: Array[Dictionary] = []
	var passed: bool = true
	for id: String in registry.module_ids():
		var result: Dictionary = await module_scenario(id)
		var observation: Dictionary = active_module.observe().duplicate(true)
		var unknown: Dictionary = _request_operation("invalid.unknown", {})
		result["checks"].append({"name": "unknown-operation-preserves-state", "passed": not unknown["ok"] and active_module.observe() == observation})
		var primary: Dictionary = active_module.primary_operation()
		var bad_arguments: Dictionary = primary.get("arguments", {}).duplicate(true)
		bad_arguments["unexpected_argument"] = true
		var invalid: Dictionary = _request_operation(primary["operation"], bad_arguments)
		result["checks"].append({"name": "invalid-arguments-preserve-state", "passed": not invalid["ok"] and active_module.observe() == observation})
		command("reset", "", false)
		primary = active_module.primary_operation()
		var stale: Dictionary = operation_bus.submit({"operation": primary["operation"], "arguments": primary["arguments"],
			"request_id": "stale-" + id, "epoch": operation_bus.observation()["epoch"] - 1})
		result["checks"].append({"name": "reset-rejects-stale-epoch", "passed": not stale["ok"] and stale["code"] == "STALE_EPOCH"})
		var first: Dictionary = _request_operation(primary["operation"], primary["arguments"])
		observation = _operation_effects_observation()
		var retry_revision: int = operation_bus.observation()["revision"]
		var retry: Dictionary = operation_bus.submit({"operation": primary["operation"], "arguments": primary["arguments"], "request_id": first["request_id"]})
		result["checks"].append({"name": "idempotent-retry-preserves-state", "passed": retry == first and _operation_effects_observation() == observation and operation_bus.observation()["revision"] == retry_revision})
		command("enter", id, false)
		result["checks"].append({"name": "reentry-fresh-revision", "passed": active_module.observe().get("revision", -1) == 0})
		for check: Dictionary in result["checks"]:
			result["passed"] = result["passed"] and check["passed"]
		var snapshots: String = _argument("--snapshots=")
		if not snapshots.is_empty() and DisplayServer.get_name() != "headless":
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var image: Image = get_viewport().get_texture().get_image()
			if image.save_png(snapshots.path_join(id + ".png")) != OK:
				result["passed"] = false
		results.append(result)
		passed = passed and result["passed"]
	command("hub", "", false)
	var report: Dictionary = {"passed": passed, "prototype_results": results,
		"expected_module_ids": registry.module_ids(),
		"full_contract_qualification": false, "engine": Engine.get_version_info()["string"]}
	for argument: String in args:
		if argument.begins_with("--report="):
			var file: FileAccess = FileAccess.open(argument.trim_prefix("--report="), FileAccess.WRITE)
			if file == null:
				push_error("Cannot write prototype verification report")
				get_tree().quit(1)
				return
			file.store_string(JSON.stringify(report, "  "))
	print("MODULE_GATE " + ("PASS" if passed else "FAIL"))
	get_tree().quit(0 if passed else 1)


func _record_start(op: RefCounted) -> void:
	_release_inputs()
	command("enter", "motion", false)
	record_commands.clear()
	record_op = op
	record_start_tick = tick
	replay_action_origin = action_count


func _record_stop(op: RefCounted) -> void:
	var duration: int = tick - record_start_tick
	var result: Dictionary = _semantic_state(action_count - replay_action_origin)
	op.event("RUN_END", duration * 1000.0 / 60.0, result)
	var payload: Dictionary = {"version": 1, "duration_ticks": duration,
		"commands": record_commands, "final_state": result}
	record_op = null
	_release_inputs()
	op.complete(result, JSON.stringify(payload).to_utf8_buffer(), "godot-lab-input-v1")


func _replay_prepare(op: RefCounted) -> void:
	if op.replay_payload.size() > 4 * 1024 * 1024:
		op.fail("BAD_REPLAY", "Payload exceeds 4 MiB")
		return
	var data: Variant = JSON.parse_string(op.replay_payload.get_string_from_utf8())
	if not data is Dictionary or data.get("version") != 1 or not data.get("commands") is Array:
		op.fail("BAD_REPLAY", "Expected godot-lab-input-v1 payload")
		return
	if not data.get("duration_ticks") is float and not data.get("duration_ticks") is int:
		op.fail("BAD_REPLAY", "Missing duration")
		return
	replay_commands = data["commands"]
	replay_duration = int(data["duration_ticks"])
	if data["duration_ticks"] != replay_duration or replay_duration < 0 or replay_duration > 216000 or replay_commands.size() > 200000:
		op.fail("BAD_REPLAY", "Replay exceeds bounds")
		return
	if not data.get("final_state") is Dictionary:
		op.fail("BAD_REPLAY", "Missing expected final state")
		return
	var expected: Dictionary = data["final_state"]
	if not expected.get("lab") is String or (not IDS.has(expected["lab"]) and expected["lab"] != "hub"):
		op.fail("BAD_REPLAY", "Invalid final lab")
		return
	for field: String in ["actions", "material_mode"]:
		var number: Variant = expected.get(field)
		if (not number is float and not number is int) or number != int(number) or number < 0:
			op.fail("BAD_REPLAY", "Invalid final counter")
			return
	replay_expected = {"lab": expected["lab"], "actions": int(expected["actions"]),
		"material_mode": int(expected["material_mode"])}
	var previous_tick: int = 0
	for item: Variant in replay_commands:
		if not item is Dictionary or not item.has_all(["tick", "kind", "value"]):
			op.fail("BAD_REPLAY", "Malformed command")
			return
		if not item["tick"] is float and not item["tick"] is int:
			op.fail("BAD_REPLAY", "Invalid command tick")
			return
		if item["tick"] != int(item["tick"]) or item["tick"] < previous_tick or item["tick"] > replay_duration:
			op.fail("BAD_REPLAY", "Command ticks must be ordered within duration")
			return
		previous_tick = int(item["tick"])
		if not item["kind"] is String or not item["value"] is String:
			op.fail("BAD_REPLAY", "Command names must be strings")
			return
		if not ["enter", "hub", "activate", "reset", "press", "release"].has(item["kind"]):
			op.fail("BAD_REPLAY", "Unknown operation")
			return
		if item["kind"] == "enter" and not IDS.has(item["value"]):
			op.fail("BAD_REPLAY", "Unknown lab")
			return
		if item["kind"] in ["press", "release"] and not ["move_left", "move_right", "move_up", "move_down", "jump"].has(item["value"]):
			op.fail("BAD_REPLAY", "Unknown input action")
			return
	_release_inputs()
	command("enter", "motion", false)
	op.mark_ready()


func _replay_start(op: RefCounted) -> void:
	replay_cursor = 0
	replay_start_tick = tick
	replay_action_origin = action_count
	replay_op = op


func _semantic_state(actions: int) -> Dictionary:
	return {"lab": current, "material_mode": world.material_mode, "actions": actions}


func _release_inputs() -> void:
	for action: String in ["move_left", "move_right", "move_up", "move_down", "jump"]:
		Input.action_release(action)


func wait_ticks(count: int) -> void:
	for i: int in range(count):
		await get_tree().physics_frame


func scenario(id: String, op: RefCounted = null) -> Dictionary:
	command("enter", id, false)
	await wait_ticks(30)
	var passed: bool = false
	var observed: Dictionary = {}
	match id:
		"motion":
			var start: Vector3 = player.position
			command("press", "move_right", false)
			command("press", "jump", false)
			await wait_ticks(2)
			command("release", "jump", false)
			await wait_ticks(50)
			command("release", "move_right", false)
			await wait_ticks(45)
			passed = player.position.distance_to(start) > 2 and player.is_on_floor() and player.jumps > motion_jumps
			observed = {"distance": player.position.distance_to(start), "landed": player.is_on_floor(), "jumps": player.jumps - motion_jumps}
		"physics":
			command("activate", "", false)
			await wait_ticks(250)
			passed = is_instance_valid(launched) and launched.position.x > -4 and launched.position.y < 2 and launched.linear_velocity.length() < 0.4
			observed = {"bodies": world.bodies.size(), "x": launched.position.x, "height": launched.position.y, "speed": launched.linear_velocity.length()}
		"navigation":
			command("activate", "", false)
			await wait_ticks(330)
			passed = world.nav_arrived and world.nav_path_peak >= 3
			observed = {"arrived": world.nav_arrived, "path_points": world.nav_path_peak, "destination_error": world.nav_actor.position.distance_to(Vector3(7, 0.4, 0))}
		"materials":
			command("activate", "", false)
			await wait_ticks(40)
			passed = world.material_mode == 1 and not world.sample_materials[0].get_shader_parameter("authored_only")
			observed = {"mode": world.material_mode, "samples": world.sample_materials.size(), "texture_size": 32}
		"audio":
			player.teleport(Vector3(-5, 0.2, 0))
			command("activate", "", false)
			if op != null:
				op.event("AUDIO_PHASE", op.elapsed_msec(), {"phase": "near"})
			await wait_ticks(120)
			player.teleport(Vector3(9, 0.2, 8))
			if op != null:
				op.event("AUDIO_PHASE", op.elapsed_msec(), {"phase": "far"})
			await wait_ticks(120)
			player.teleport(Vector3(-9, 0.2, -2))
			if op != null:
				op.event("AUDIO_PHASE", op.elapsed_msec(), {"phase": "left"})
			await wait_ticks(120)
			player.teleport(Vector3(0, 0.2, -2))
			if op != null:
				op.event("AUDIO_PHASE", op.elapsed_msec(), {"phase": "right"})
			await wait_ticks(120)
			passed = world.audio.playing and world.audio_on and world.audio.max_distance == 22
			observed = {"playing": world.audio.playing, "spatial_source": world.audio is AudioStreamPlayer3D, "frequency_hz": 220}
		"persistence":
			command("activate", "", false)
			await wait_ticks(60)
			var reader: RefCounted = StoreScript.new()
			reader.path = store.path
			passed = reader.load_progress() == OK and reader.completed.has("persistence")
			observed = {"round_trip": passed, "seals": reader.completed.size(), "schema": 1}
	_release_inputs()
	return {"lab": id, "passed": passed, "observed": observed}


func _argument(prefix: String) -> String:
	for argument: String in args:
		if argument.begins_with(prefix):
			return argument.substr(prefix.length())
	return ""


func _snapshot(name: String) -> void:
	var directory: String = _argument("--snapshots=")
	if directory.is_empty() or DisplayServer.get_name() == "headless":
		return
	DirAccess.make_dir_recursive_absolute(directory)
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var result: Error = image.save_png(directory.path_join(name + ".png"))
	if result != OK:
		push_error("Snapshot failed: " + error_string(result))


func _run_tour() -> void:
	await wait_ticks(90)
	await _snapshot("hub")
	for id: String in IDS:
		var result: Dictionary = await scenario(id)
		print("LAB_PROOF " + JSON.stringify(result))
		await _snapshot(id)
		await wait_ticks(60)
	command("hub", "", false)
	await wait_ticks(90)
	get_tree().quit()


func _run_verification() -> void:
	store.completed.clear()
	var results: Array[Dictionary] = []
	await wait_ticks(5)
	# Actual hub portal path, also exercises the common operation used by the UI.
	player.teleport(world.portals[0] + Vector3(0, 0.2, 1))
	command("activate", "", false)
	results.append({"lab": "hub_portal", "passed": current == "motion"})
	for id: String in IDS:
		var result: Dictionary = await scenario(id)
		results.append(result)
		print("LAB_PROOF " + JSON.stringify(result))
		await _snapshot(id)
		command("reset", "", false)
		var reset_ok: bool = current == id and player.position.distance_to(Vector3(0, 0.2, 6)) < 0.1
		match id:
			"physics": reset_ok = reset_ok and world.bodies.size() == 6
			"navigation": reset_ok = reset_ok and not world.nav_go and not world.nav_arrived
			"materials": reset_ok = reset_ok and world.material_mode == 0
			"audio": reset_ok = reset_ok and not world.audio_on and not world.audio.playing
		results.append({"lab": id + "_reset", "passed": reset_ok})
	command("enter", "motion", false)
	player.teleport(Vector3(0, 0.2, 5))
	await wait_ticks(15)
	command("press", "move_up", false)
	command("press", "move_right", false)
	await wait_ticks(60)
	_release_inputs()
	results.append({"lab": "solid_collision", "passed": player.position.z >= 3.2 and player.position.z < 4,
		"observed_z": player.position.z})
	# Exercise keyboard and controller adapters through Godot's real input dispatch.
	var key: InputEventKey = InputEventKey.new()
	key.physical_keycode = KEY_2
	key.pressed = true
	Input.parse_input_event(key)
	await wait_ticks(2)
	results.append({"lab": "keyboard_route", "passed": current == "physics"})
	var button: InputEventJoypadButton = InputEventJoypadButton.new()
	button.button_index = JOY_BUTTON_X
	button.pressed = true
	Input.parse_input_event(button)
	await wait_ticks(2)
	results.append({"lab": "synthetic_controller_action", "passed": world.bodies.size() == 7})
	button.pressed = false
	Input.parse_input_event(button)
	var before: int = world.bodies.size()
	command("enter", "physics", false)
	command("activate", "", false)
	command("reset", "", false)
	results.append({"lab": "reset", "passed": world.bodies.size() == 6, "before": before})
	command("hub", "", false)
	results.append({"lab": "return_to_hub", "passed": current == "hub" and world.portals.size() == 6})
	var reader: RefCounted = StoreScript.new()
	reader.path = store.path
	var reload_ok: bool = reader.load_progress() == OK
	results.append({"lab": "all_seals_persisted", "passed": reload_ok and reader.completed.size() == 6})
	# Malformed local fixture must be rejected rather than treated as valid progress.
	reader.path = "user://godot-lab/negative-control.json"
	var bad: FileAccess = FileAccess.open(reader.path, FileAccess.WRITE)
	bad.store_string("{\"schema_version\":2,\"completed\":[]}")
	bad.close()
	results.append({"lab": "invalid_schema_rejected", "passed": reader.load_progress() == ERR_INVALID_DATA})
	bad = FileAccess.open(reader.path, FileAccess.WRITE)
	bad.store_string("{\"schema_version\":1")
	bad.close()
	results.append({"lab": "truncated_save_rejected", "passed": reader.load_progress() == ERR_PARSE_ERROR})
	bad = FileAccess.open(reader.path, FileAccess.WRITE)
	bad.store_string("{\"schema_version\":1,\"completed\":[\"motion\",\"unknown\"]}")
	bad.close()
	results.append({"lab": "unknown_lab_rejected", "passed": reader.load_progress() == ERR_INVALID_DATA and reader.completed.is_empty()})
	var preserved: String = FileAccess.get_file_as_string(reader.path)
	results.append({"lab": "invalid_save_preserved", "passed": reader.complete_lab("audio") == ERR_INVALID_DATA and FileAccess.get_file_as_string(reader.path) == preserved})
	DirAccess.remove_absolute(ProjectSettings.globalize_path(reader.path))
	var success: bool = true
	for result: Dictionary in results:
		success = success and result["passed"]
	var report: Dictionary = {"schema_version": 1, "passed": success, "engine": Engine.get_version_info(),
		"mode": "headless" if DisplayServer.get_name() == "headless" else "rendered", "checks": results}
	var report_path: String = _argument("--report=")
	if not report_path.is_empty():
		var file: FileAccess = FileAccess.open(report_path, FileAccess.WRITE)
		if file == null:
			push_error("Cannot write verification report")
			success = false
		else:
			file.store_string(JSON.stringify(report, "\t"))
			file.close()
	print("GODOT_LAB_VERIFY " + ("PASS" if success else "FAIL"))
	get_tree().quit(0 if success else 1)


func _inspect_save() -> void:
	var success: bool = store.last_error.is_empty() and store.completed.size() == 6
	var report: Dictionary = {"passed": success, "seals": store.completed.size(), "mode": "process_restart"}
	var file: FileAccess = FileAccess.open(_argument("--report="), FileAccess.WRITE)
	if file == null:
		push_error("Cannot write restart receipt")
		success = false
	else:
		file.store_string(JSON.stringify(report))
		file.close()
	print("RESTART_GATE " + ("PASS" if success else "FAIL"))
	get_tree().quit(0 if success else 1)
