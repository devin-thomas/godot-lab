extends "res://labs/lab_module.gd"
const Domain = preload("res://labs/systems/system_domain.gd")
const DragCard = preload("res://labs/systems/drag_card.gd")
const Emitter = preload("res://labs/systems/signal_fixture.gd")
const TileCanvas = preload("res://labs/systems/tile_canvas.gd")
var lab_id: String = "LAB-007"
var domain: RefCounted
var readout: RichTextLabel
var figures: Array[MeshInstance3D] = []
var figure_origins: Array[Vector3] = []
var locale_label: Label
var controls_root: Control
var phase: float = 0.0
var preview_remaining: float = 0.0
const TITLES: Dictionary = {"LAB-007": "Tile Workshop", "LAB-012": "Input Atelier", "LAB-013": "UI Workshop", "LAB-014": "Dialogue Machine", "LAB-018": "Resource Cabinet", "LAB-037": "Capability Compass", "LAB-038": "Operation Desk", "LAB-039": "Fixture Pantry", "LAB-040": "Pause Vestibule", "LAB-041": "Signal Switchboard", "LAB-074": "Statechart Playhouse", "LAB-075": "Quest Weave", "LAB-077": "Inventory Alchemy", "LAB-078": "Locale Pavilion", "LAB-079": "Focus Labyrinth", "LAB-080": "Comfort Controls", "LAB-081": "Drag & Inspect"}
const EXPLANATIONS: Dictionary = {
	"LAB-007": "Paint the 8 x 5 room. Wall tiles own TileSet collision; the courier moves one cell. Undo restores cells and neighbor edges.",
	"LAB-012": "Bind J or K, then press that key. Synthetic A-button input shares InputMap dispatch. Space and Escape remain reserved.",
	"LAB-013": "Tab through named controls. Change a setting, open a dialog, and close it to restore its originating focus.",
	"LAB-014": "Help the harbor keeper, light the beacon, then sail. Undo restores both node and flags. Secret requires prior help.",
	"LAB-018": "Edit the lantern, save a real custom .tres Resource, change it, then reload uncached bytes and texture dependency.",
	"LAB-037": "Search payoffs and inspect live installed-engine API readiness. The XR card explains its unavailable route.",
	"LAB-038": "Move the courier with a typed request ID and expected revision. Retrying one ID applies once. Undo restores the previous pose.",
	"LAB-039": "Stage original JSON fixtures with size, provenance and SHA-256. Commit changes the exhibit; cancellation preserves it.",
	"LAB-040": "Advance owned simulation ticks. Pause disables the mover node while inspector controls remain usable. Cancel prevents late work.",
	"LAB-041": "Connect a lever signal to the gate and lamp. Duplicate wiring stays single. Trigger, disconnect and inspect ordered deliveries.",
	"LAB-074": "Start, jump, land and interrupt the courier statechart. Energy guards jumping. Entry and exit hooks count once per transition.",
	"LAB-075": "Collect glass and brass in either order, repair the lantern, then light the beacon. Duplicate objectives award once; undo follows reverse order.",
	"LAB-077": "Preview recipe quantities, commit the exact proposal, then undo. Ingredient and slot capacity checks preserve the inventory on failure.",
	"LAB-078": "Switch original English, Spanish and Arabic fixture messages through TranslationServer. Inspect long text, direction and bounded plural examples.",
	"LAB-079": "Navigate enabled controls, open nested dialogs and return to origin. The assistive probe reports API availability and its unqualified human route.",
	"LAB-080": "Motion and flash start disabled. Adjust text scale and assistance, then preview a single brief effect. Preferences are scoped to this lab.",
	"LAB-081": "Drag the sea-glass card onto the material slot, or use the keyboard Stage button. Inspect the proposal, commit, cancel or undo."}

func setup(context: Dictionary) -> void:
	super.setup(context)
	domain = Domain.new()
	domain.configure(lab_id, context)
	super.sign(String(TITLES.get(lab_id, lab_id)), Vector3(0, 4.3, -3.5), GOLD, 38)
	for index: int in range(3):
		var at := Vector3(float(index - 1) * 3.1, 1.1, -2.0)
		box(at - Vector3(0, 0.8, 0), Vector3(2.2, 0.6, 2.2), INK)
		var figure: MeshInstance3D = box(at, Vector3(1.4, 1.8 + float(index) * 0.2, 1.3), [MINT, GOLD, CORAL][index])
		figures.append(figure)
		figure_origins.append(at)
	_build_silhouettes()
	if lab_id == "LAB-041":
		domain.emitter = Emitter.new()
		add_child(domain.emitter)
	if lab_id == "LAB-040":
		domain.motion_root = figures[0]
	_update_visuals()

func describe() -> Dictionary:
	return {"id": lab_id, "title": TITLES.get(lab_id, lab_id), "description": EXPLANATIONS.get(lab_id, ""), "action": "Operate", "label": "Operate fixture", "ready": domain != null, "limits": _limits()}

func operations() -> Array[Dictionary]:
	return domain.operations() if domain != null else []

func apply_operation(name: String, args: Dictionary) -> Dictionary:
	if domain == null: return {"ok": false, "code": "NOT_PREPARED"}
	var result: Dictionary = domain.apply_operation(name, args)
	if name == "comfort.preview" and bool(result.get("ok", false)): preview_remaining = 0.3
	_update_visuals()
	return result

func primary_operation() -> Dictionary:
	if domain == null: return {}
	var state: Dictionary = domain.state
	match lab_id:
		"LAB-007": return _action("tiles.paint", {"x": 2, "y": 2, "tile": 1})
		"LAB-012": return _action("input.invoke", {"device": "keyboard"})
		"LAB-013": return _action("ui.set_setting", {"enabled": not bool(state.setting)})
		"LAB-014":
			var choices: Dictionary = {"arrival": "help", "repair": "light", "beacon": "sail", "harbor": "sail", "keeper": "promise", "promise": "depart", "farewell": "depart", "storm": "shelter", "tower": "wait", "dawn": "sail"}
			return _action("dialogue.choose", {"choice": choices.get(state.node, "return")})
		"LAB-018": return _action("resources.save")
		"LAB-037": return _action("catalog.search", {"query": "paint"})
		"LAB-038": return _action("operations.move", {"position": posmod(int(state.position) + 4, 7) - 3, "request": "player-%s" % domain.revision, "expected_revision": domain.revision})
		"LAB-039": return _action("fixtures.stage", {"fixture": "mint"})
		"LAB-040": return _action("lifecycle.resume" if state.paused else "lifecycle.pause")
		"LAB-041": return _action("signals.emit_event", {"source": "lever"}) if state.connected else _action("signals.connect_route")
		"LAB-074": return _action("statechart.event", {"event": {"idle": "start", "walking": "jump", "airborne": "land"}[state.mode]})
		"LAB-075":
			for objective: String in ["glass", "brass", "repair", "beacon"]:
				if objective not in state.objectives: return _action("quests.record", {"objective": objective})
			return _action("quests.record", {"objective": "beacon"})
		"LAB-077": return _action("inventory.commit") if not domain.proposals.is_empty() else _action("inventory.preview", {"recipe": "lantern"})
		"LAB-078": return _action("locale.select", {"code": "es" if state.locale == "en" else "en"})
		"LAB-079": return _action("focus.navigate", {"direction": "next"})
		"LAB-080": return _action("comfort.preview")
		"LAB-081": return _action("drag.commit") if not domain.proposals.is_empty() else _action("drag.stage", {"payload": "sea-glass", "target": "material-slot"})
	return {}

func observe() -> Dictionary:
	return domain.observe() if domain != null else {"ready": false}

func reset() -> Dictionary:
	if domain == null: return {"ok": false, "code": "NOT_PREPARED"}
	preview_remaining = 0.0
	phase = 0.0
	var result: Dictionary = domain.reset()
	_update_visuals()
	return result

func teardown() -> void:
	if domain != null: domain.teardown()
	super.teardown()

func create_controls(parent: Control) -> void:
	var existing: Array[Node] = parent.get_children()
	controls_root = parent
	var explanation := Label.new()
	explanation.text = String(EXPLANATIONS.get(lab_id, ""))
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explanation.custom_minimum_size.x = 300
	parent.add_child(explanation)
	var grid := GridContainer.new()
	grid.columns = 2
	parent.add_child(grid)
	match lab_id:
		"LAB-007":
			_create_tiles(parent)
			var x := SpinBox.new()
			x.max_value = 7
			x.value = 2
			x.prefix = "X "
			grid.add_child(x)
			var y := SpinBox.new()
			y.max_value = 4
			y.value = 2
			y.prefix = "Y "
			grid.add_child(y)
			var brush := OptionButton.new()
			for label: String in ["Floor / erase", "Solid brass", "Sea-glass"]: brush.add_item(label)
			brush.select(1)
			grid.add_child(brush)
			var paint := Button.new()
			paint.text = "Paint coordinate"
			paint.pressed.connect(func() -> void: request_operation.emit("tiles.paint", {"x": int(x.value), "y": int(y.value), "tile": brush.selected}))
			grid.add_child(paint)
			brush.item_selected.connect(func(index: int) -> void: tile_canvas.selected_brush = index)
			for tile: int in range(3): _button(grid, ["Paint floor", "Paint solid wall", "Paint sea-glass"][tile], "tiles.paint", {"x": 2, "y": 2, "tile": tile})
			for direction: String in ["left", "right", "up", "down"]: _button(grid, "Walk " + direction, "tiles.move", {"direction": direction})
			_button(grid, "Undo paint", "tiles.undo")
		"LAB-012":
			for key: String in ["J", "K", "ESCAPE"]: _button(grid, "Bind " + key, "input.bind", {"action": "interact", "key": key})
			_button(grid, "Try keyboard", "input.invoke", {"device": "keyboard"})
			_button(grid, "Try synthetic pad A", "input.invoke", {"device": "pad"})
			_button(grid, "Restore J", "input.restore_defaults")
		"LAB-013", "LAB-079": _create_focus(grid)
		"LAB-014":
			for choice: String in ["help", "leave", "secret", "light", "sail", "listen", "promise", "depart", "return", "shelter", "wait"]: _button(grid, choice.capitalize(), "dialogue.choose", {"choice": choice})
			_button(grid, "Undo choice", "dialogue.undo")
		"LAB-018":
			_button(grid, "Charge lantern: 7", "resources.edit", {"name": "Tide lantern", "charge": 7})
			_button(grid, "Drain lantern: 1", "resources.edit", {"name": "Harbor lantern", "charge": 1})
			_button(grid, "Save .tres", "resources.save")
			_button(grid, "Reload disk bytes", "resources.reload")
		"LAB-037":
			var search := LineEdit.new()
			search.placeholder_text = "Search payoff: paint, save, headset"
			search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			parent.add_child(search)
			search.text_submitted.connect(func(query: String) -> void: request_operation.emit("catalog.search", {"query": query}))
			_button(grid, "Search paint", "catalog.search", {"query": "paint"})
			for target: String in ["LAB-007", "LAB-018", "LAB-092"]: _button(grid, "Probe " + target, "catalog.probe", {"id": target})
		"LAB-038":
			for position: int in [-3, 0, 3]:
				var button := Button.new()
				button.text = "Move to %s" % position
				grid.add_child(button)
				button.pressed.connect(func() -> void: request_operation.emit("operations.move", {"position": position, "request": "ui-%s" % domain.revision, "expected_revision": domain.revision}))
			_button(grid, "Undo pose", "operations.undo")
		"LAB-039":
			for fixture: String in ["stone", "mint", "brass", "oversized"]: _button(grid, "Stage " + fixture, "fixtures.stage", {"fixture": fixture})
			_button(grid, "Commit fixture", "fixtures.commit")
			_button(grid, "Cancel staging", "fixtures.cancel")
		"LAB-040":
			_button(grid, "Advance one second", "lifecycle.step", {"ticks": 60})
			_button(grid, "Pause owned mover", "lifecycle.pause")
			_button(grid, "Resume", "lifecycle.resume")
			_button(grid, "Cancel owned job", "lifecycle.cancel")
		"LAB-041":
			_button(grid, "Connect lever route", "signals.connect_route")
			_button(grid, "Trigger lever", "signals.emit_event", {"source": "lever"})
			_button(grid, "Trigger bell", "signals.emit_event", {"source": "bell"})
			_button(grid, "Disconnect route", "signals.disconnect")
		"LAB-074":
			for event: String in ["start", "jump", "land", "stop", "interrupt"]: _button(grid, event.capitalize(), "statechart.event", {"event": event})
		"LAB-075":
			for objective: String in ["glass", "brass", "repair", "beacon", "flowers"]: _button(grid, objective.capitalize(), "quests.record", {"objective": objective})
			_button(grid, "Undo objective", "quests.undo")
		"LAB-077":
			for recipe: String in ["lantern", "glass-lantern", "brass-lantern"]: _button(grid, "Preview " + recipe, "inventory.preview", {"recipe": recipe})
			_button(grid, "Commit recipe", "inventory.commit")
			_button(grid, "Undo craft", "inventory.undo")
		"LAB-078":
			for code: String in ["en", "es", "ar"]: _button(grid, "Locale " + code, "locale.select", {"code": code})
			for count: int in [0, 1, 2, 25]: _button(grid, "Format %s" % count, "locale.format", {"count": count})
			locale_label = Label.new()
			locale_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			locale_label.custom_minimum_size.y = 64
			parent.add_child(locale_label)
		"LAB-080":
			_button(grid, "Calm + larger text", "comfort.apply", {"motion": false, "flash": false, "text_scale": 1.4, "assist": true})
			_button(grid, "Single motion preview", "comfort.apply", {"motion": true, "flash": false, "text_scale": 1.0, "assist": false})
			_button(grid, "Single flash preview", "comfort.apply", {"motion": false, "flash": true, "text_scale": 1.0, "assist": false})
			_button(grid, "Run brief preview", "comfort.preview")
		"LAB-081":
			var source := DragCard.new()
			source.text = "Drag sea-glass card"
			grid.add_child(source)
			var slot := DragCard.new()
			slot.text = "Material slot: drop here"
			slot.accepts_drop = true
			grid.add_child(slot)
			slot.stage_requested.connect(func(payload: String, target: String) -> void: request_operation.emit("drag.stage", {"payload": payload, "target": target}))
			_button(grid, "Stage (keyboard)", "drag.stage", {"payload": "sea-glass", "target": "material-slot"})
			_button(grid, "Commit drop", "drag.commit")
			_button(grid, "Cancel drop", "drag.cancel")
			_button(grid, "Undo assignment", "drag.undo")
	readout = RichTextLabel.new()
	readout.fit_content = true
	readout.scroll_active = false
	readout.custom_minimum_size.x = 300
	parent.add_child(readout)
	_update_visuals()
	for child: Node in parent.get_children():
		if child not in existing: _controls.append(child)

func _build_silhouettes() -> void:
	match lab_id:
		"LAB-014", "LAB-074":
			for index: int in range(3):
				var mask := PrismMesh.new()
				mask.size = Vector3(1.6, 2.1, 1.1)
				figures[index].mesh = mask
				for offset: float in [-0.4, 0.4]: box(figure_origins[index] + Vector3(offset, 0.35, 0.61), Vector3(0.28, 0.2, 0.1), INK)
				box(figure_origins[index] + Vector3(0, -0.2, 0.65), Vector3(0.6, 0.12, 0.1), INK)
		"LAB-018", "LAB-077", "LAB-078":
			for index: int in range(3):
				var lantern := CylinderMesh.new()
				lantern.top_radius = 0.65
				lantern.bottom_radius = 0.85
				lantern.height = 1.9
				lantern.radial_segments = 6
				figures[index].mesh = lantern
				box(figure_origins[index] + Vector3(0, 1.15, 0), Vector3(1.9, 0.25, 1.9), GOLD)
				box(figure_origins[index] + Vector3(0, 1.55, 0), Vector3(0.2, 0.7, 0.2), GOLD)
		"LAB-037":
			for index: int in range(3):
				var ring := TorusMesh.new()
				ring.inner_radius = 0.7
				ring.outer_radius = 1.0
				ring.rings = 12
				ring.ring_segments = 6
				figures[index].mesh = ring
				figures[index].rotation.x = PI / 2.0
				box(figure_origins[index] + Vector3(0, 0.8, 0), Vector3(0.15, 1.0, 0.3), CORAL)
		"LAB-041":
			figures[1].mesh = _sized_box(Vector3(2.0, 2.6, 0.4))
			for x: float in [-1.3, 1.3]: box(Vector3(x, 1.6, -2), Vector3(0.35, 3.2, 0.7), GOLD)
			box(Vector3(0, 3.3, -2), Vector3(3.0, 0.35, 0.8), GOLD)
			figures[0].mesh = _sized_box(Vector3(0.3, 2, 0.3))
		"LAB-075":
			for index: int in range(3):
				figures[index].mesh = _sized_box(Vector3(1.8, 0.15, 1.3))
				box(figure_origins[index] - Vector3(0, 0.5, 0), Vector3(0.2, 2.0, 0.2), GOLD)
		"LAB-007", "LAB-013", "LAB-079", "LAB-081", "LAB-039":
			for index: int in range(3):
				figures[index].mesh = _sized_box(Vector3(2.0, 1.3, 0.25))
				box(figure_origins[index] + Vector3(0, 0.85, 0), Vector3(2.4, 0.15, 0.5), GOLD)
		_:
			for index: int in range(3):
				var courier := PrismMesh.new()
				courier.size = Vector3(1.5, 1.1, 2.0)
				figures[index].mesh = courier
				for side: float in [-0.85, 0.85]: box(figure_origins[index] + Vector3(side, -0.1, 0), Vector3(0.5, 0.3, 1.7), GOLD)

func _sized_box(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh

func _create_focus(parent: Control) -> void:
	var confirm: Button = _button(parent, "Confirm setting", "ui.set_setting" if lab_id == "LAB-013" else "focus.navigate", {"enabled": true} if lab_id == "LAB-013" else {"direction": "next"})
	confirm.name = "Confirm"
	var setting: Button = _button(parent, "Setting / previous", "ui.set_setting" if lab_id == "LAB-013" else "focus.navigate", {"enabled": false} if lab_id == "LAB-013" else {"direction": "previous"})
	setting.name = "Setting"
	var dialog: Button = _button(parent, "Open dialog", "ui.dialog" if lab_id == "LAB-013" else "focus.dialog", {"open": true})
	dialog.name = "DialogOrigin"
	var close: Button = _button(parent, "Close dialog / back", "ui.dialog" if lab_id == "LAB-013" else "focus.dialog", {"open": false})
	close.name = "DialogClose"
	close.visible = false
	var disabled := Button.new()
	disabled.text = "Unavailable: device gate"
	disabled.disabled = true
	disabled.focus_mode = Control.FOCUS_NONE
	parent.add_child(disabled)
	domain.focus_controls = {"confirm": confirm, "setting": setting, "dialog": dialog, "close": close}
	confirm.focus_neighbor_right = confirm.get_path_to(setting)
	setting.focus_neighbor_left = setting.get_path_to(confirm)
	setting.focus_neighbor_bottom = setting.get_path_to(dialog)
	dialog.focus_neighbor_top = dialog.get_path_to(setting)
	if lab_id == "LAB-079": _button(parent, "Probe assistive API", "focus.probe")
	confirm.grab_focus()

var tile_canvas: SubViewportContainer
func _create_tiles(parent: Control) -> void:
	var container := TileCanvas.new()
	tile_canvas = container
	container.paint_requested.connect(func(x: int, y: int, tile: int) -> void: request_operation.emit("tiles.paint", {"x": x, "y": y, "tile": tile}))
	container.custom_minimum_size = Vector2(256, 160)
	container.stretch = true
	container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(container)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(256, 160)
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.world_2d = World2D.new()
	container.add_child(viewport)
	# Sixteen authored wall edge masks make each painted neighbor seam visible.
	var image := Image.create(288, 16, false, Image.FORMAT_RGBA8)
	for x: int in range(288):
		for y: int in range(16):
			var tile: int = x / 16
			var local_x: int = x % 16
			var color: Color = STONE if tile == 0 else (MINT if tile == 17 else GOLD)
			if tile > 0 and tile < 17:
				var mask: int = tile - 1
				if (y == 0 and (mask & 1) == 0) or (local_x == 15 and (mask & 2) == 0) or (y == 15 and (mask & 4) == 0) or (local_x == 0 and (mask & 8) == 0): color = INK
			elif local_x == 0 or y == 0: color = color.darkened(0.15)
			image.set_pixel(x, y, color)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = ImageTexture.create_from_image(image)
	atlas.texture_region_size = Vector2i(16, 16)
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(16, 16)
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 1)
	for tile: int in range(18):
		atlas.create_tile(Vector2i(tile, 0))
	tileset.add_source(atlas, 0)
	for tile: int in range(1, 17):
		var wall: TileData = atlas.get_tile_data(Vector2i(tile, 0), 0)
		wall.set_collision_polygons_count(0, 1)
		wall.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8)]))
	var map := TileMapLayer.new()
	map.tile_set = tileset
	map.scale = Vector2(2, 2)
	viewport.add_child(map)
	var body := CharacterBody2D.new()
	body.collision_layer = 2
	body.collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 6
	shape.shape = circle
	body.add_child(shape)
	var courier := Polygon2D.new()
	courier.polygon = PackedVector2Array([Vector2(0, -8), Vector2(7, 6), Vector2(-7, 6)])
	courier.color = CORAL
	body.add_child(courier)
	viewport.add_child(body)
	domain.tile_map = map
	domain.tile_body = body
	domain._sync_tiles()

func _button(parent: Control, text: String, operation: String, args: Dictionary = {}) -> Button:
	var button := Button.new()
	button.text = text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(func() -> void: request_operation.emit(operation, args.duplicate(true)))
	parent.add_child(button)
	return button

func _update_visuals() -> void:
	if domain == null: return
	var state: Dictionary = domain.state
	for index: int in range(figures.size()):
		figures[index].position = figure_origins[index]
		figures[index].rotation = Vector3.ZERO
		figures[index].scale = Vector3.ONE
	match lab_id:
		"LAB-038": figures[0].position.x = float(state.position)
		"LAB-041":
			figures[1].position.y += 2.2 if state.gate else 0.0
			figures[2].material_override = material(MINT if state.lamp else INK)
		"LAB-074":
			figures[0].position.y += 1.5 if state.mode == "airborne" else 0.0
			figures[0].rotation.z = -0.2 if state.mode == "walking" else 0.0
		"LAB-039": figures[0].material_override = material({"stone": STONE, "mint": MINT, "brass": GOLD}.get(state.active, STONE))
		"LAB-081": figures[0].material_override = material(MINT if state.assignment == "sea-glass" else STONE)
		"LAB-075":
			for index: int in range(3): figures[index].scale.y = 1.0 + float(state.objectives.size()) * 0.12
		"LAB-077":
			figures[0].scale.y = 0.3 + float(state.items.glass) * 0.2
			figures[1].scale.y = 0.3 + float(state.items.brass) * 0.3
			figures[2].scale.y = 0.3 + float(state.items.lantern) * 0.7
		"LAB-018":
			figures[0].scale.y = 0.4 + float(state.charge) * 0.12
			var surface: StandardMaterial3D = material(Color.WHITE)
			surface.albedo_texture = domain.item.surface
			surface.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			figures[0].material_override = surface
		"LAB-040": figures[0].position.x = -3.1 + minf(float(state.distance), 5.0)
	if is_instance_valid(locale_label):
		locale_label.text = String(state.get("text", "")) + "\n" + String(state.get("formatted", ""))
		locale_label.text_direction = Control.TEXT_DIRECTION_RTL if state.get("direction") == "RTL" else Control.TEXT_DIRECTION_LTR
	if is_instance_valid(readout):
		readout.text = JSON.stringify(domain.observe(), "  ")
		readout.add_theme_font_size_override("normal_font_size", int(16.0 * float(state.get("text_scale", 1.0))))
	if lab_id in ["LAB-013", "LAB-079"] and domain.focus_controls.has("close"):
		domain.focus_controls.close.visible = int(state.dialog_depth) > 0

func _process(delta: float) -> void:
	if domain == null: return
	phase += delta
	if lab_id == "LAB-040" and not bool(domain.state.paused) and domain.state.job == "running":
		figures[0].rotation.y = phase * 0.7
	if lab_id == "LAB-080":
		preview_remaining = maxf(0.0, preview_remaining - delta)
		figures[0].position.x = figure_origins[0].x + (sin(phase * 16.0) * 0.15 if preview_remaining > 0 and domain.state.motion else 0.0)
		figures[1].material_override = material(GOLD.lightened(0.15) if preview_remaining > 0 and domain.state.flash else GOLD)

func _unhandled_input(event: InputEvent) -> void:
	if lab_id == "LAB-012" and domain != null and event.is_action_pressed("lab_system_interact") and not event.is_echo():
		request_operation.emit("input.invoke", {"device": "pad" if event is InputEventJoypadButton else "keyboard"})
		get_viewport().set_input_as_handled()

func _action(operation: String, args: Dictionary = {}) -> Dictionary: return {"operation": operation, "arguments": args}
func _step(operation: String, args: Dictionary = {}, assertions: Dictionary = {}, ok: bool = true, code: String = "") -> Dictionary:
	var step: Dictionary = {"operation": operation, "arguments": args, "expect_ok": ok, "assert": assertions}
	if not code.is_empty(): step["expect_code"] = code
	return step

func scenario() -> Array[Dictionary]:
	match lab_id:
		"LAB-007": return [_step("tiles.paint", {"x": 2, "y": 2, "tile": 1}, {"neighbor_edges": 6}), _step("tiles.move", {"direction": "right"}, {"cursor": [1, 2]}, false, "SOLID_TILE"), _step("tiles.paint", {"x": 8, "y": 1, "tile": 1}, {}, false, "INVALID_ARGUMENT"), _step("tiles.undo", {}, {"neighbor_edges": 4}), _step("tiles.move", {"direction": "right"}, {"cursor": [2, 2]}), _step("tiles.paint", {"x": 1, "y": 1, "tile": 3}, {}, false, "INVALID_ARGUMENT")]
		"LAB-012": return [_step("input.bind", {"action": "interact", "key": "K"}, {"binding": "K"}), _step("input.invoke", {"device": "keyboard"}, {"invocations": 1}), _step("input.invoke", {"device": "pad"}, {"invocations": 2, "last_device": "pad"}), _step("input.bind", {"action": "interact", "key": "ESCAPE"}, {}, false, "ESSENTIAL_BINDING_CONFLICT"), _step("input.bind", {"action": "missing", "key": "J"}, {}, false, "INVALID_ARGUMENT"), _step("input.restore_defaults", {}, {"binding": "J"})]
		"LAB-013": return [_step("ui.focus", {"target": "setting"}, {"focus": "setting"}), _step("ui.set_setting", {"enabled": true}, {"setting": true}), _step("ui.dialog", {"open": true}, {"dialog_depth": 1}), _step("ui.dialog", {"open": false}, {"focus": "setting", "dialog_depth": 0}), _step("ui.focus", {"target": "disabled"}, {}, false, "FOCUS_TARGET_MISSING"), _step("ui.dialog", {"open": false}, {}, false, "NO_OPEN_DIALOG")]
		"LAB-014": return [_step("dialogue.choose", {"choice": "secret"}, {}, false, "BRANCH_GUARD"), _step("dialogue.choose", {"choice": "help"}, {"node": "repair"}), _step("dialogue.choose", {"choice": "light"}, {"node": "beacon"}), _step("dialogue.undo", {}, {"node": "repair"}), _step("dialogue.choose", {"choice": "unknown"}, {}, false, "CHOICE_NOT_AVAILABLE"), _step("dialogue.choose", {"choice": "light"}), _step("dialogue.choose", {"choice": "sail"}), _step("dialogue.choose", {"choice": "sail"}, {"ending": "voyage"})]
		"LAB-018": return [_step("resources.edit", {"name": "Tide lantern", "charge": 7}, {"charge": 7}), _step("resources.save", {}, {"saved": true}), _step("resources.edit", {"name": "Drained", "charge": 1}), _step("resources.reload", {}, {"name": "Tide lantern", "charge": 7, "reloads": 1}), _step("resources.edit", {"name": "", "charge": 1}, {}, false, "EMPTY_NAME"), _step("resources.edit", {"name": "Bad", "charge": 10}, {}, false, "INVALID_ARGUMENT")]
		"LAB-037": return [_step("catalog.search", {"query": "paint"}, {"results": ["LAB-007"]}), _step("catalog.probe", {"id": "LAB-007"}), _step("catalog.probe", {"id": "LAB-092"}), _step("catalog.probe", {"id": "LAB-999"}, {}, false, "LAB_NOT_FOUND"), _step("catalog.search", {"query": 12}, {}, false, "INVALID_ARGUMENT")]
		"LAB-038": return [_step("operations.move", {"position": 3, "request": "move-a", "expected_revision": 0}, {"position": 3, "commits": 1}), _step("operations.move", {"position": 3, "request": "move-a", "expected_revision": 0}, {"commits": 1}), _step("operations.move", {"position": -3, "request": "move-a", "expected_revision": 0}, {}, false, "REQUEST_ID_REUSED"), _step("operations.move", {"position": -3, "request": "move-b", "expected_revision": 0}, {}, false, "REVISION_CONFLICT"), _step("operations.undo", {}, {"position": 0, "commits": 0})]
		"LAB-039": return [_step("fixtures.stage", {"fixture": "mint"}, {"active": "stone", "staged": "mint"}), _step("fixtures.cancel", {}, {"active": "stone", "staged": ""}), _step("fixtures.stage", {"fixture": "brass"}), _step("fixtures.commit", {}, {"active": "brass"}), _step("fixtures.stage", {"fixture": "oversized"}, {}, false, "FIXTURE_SIZE_LIMIT"), _step("fixtures.stage", {"fixture": "../native"}, {}, false, "EXTERNAL_PATH_REJECTED")]
		"LAB-040": return [_step("lifecycle.step", {"ticks": 60}, {"ticks": 60}), _step("lifecycle.pause", {}, {"paused": true}), _step("lifecycle.step", {"ticks": 1}, {}, false, "SIMULATION_PAUSED"), _step("lifecycle.resume", {}, {"paused": false}), _step("lifecycle.step", {"ticks": 60}, {"ticks": 120}), _step("lifecycle.cancel", {}, {"job": "cancelled"}), _step("lifecycle.step", {"ticks": 1}, {}, false, "JOB_CANCELLED")]
		"LAB-041": return [_step("signals.connect_route"), _step("signals.connect_route"), _step("signals.emit_event", {"source": "lever"}, {"deliveries": 1, "gate": true}), _step("signals.emit_event", {"source": "bell"}, {"deliveries": 2, "gate": false}), _step("signals.disconnect"), _step("signals.emit_event", {"source": "lever"}, {"deliveries": 2}), _step("signals.emit_event", {"source": "unknown"}, {}, false, "INVALID_ARGUMENT"), _step("signals.missing", {}, {}, false, "UNKNOWN_OPERATION")]
		"LAB-074": return [_step("statechart.event", {"event": "jump"}, {}, false, "TRANSITION_NOT_ALLOWED"), _step("statechart.event", {"event": "start"}, {"mode": "walking"}), _step("statechart.event", {"event": "jump"}, {"mode": "airborne", "energy": 1}), _step("statechart.event", {"event": "interrupt"}, {"mode": "idle", "interrupts": 1, "entries": 3, "exits": 3}), _step("statechart.event", {"event": "missing"}, {}, false, "TRANSITION_NOT_ALLOWED")]
		"LAB-075": return [_step("quests.record", {"objective": "repair"}, {}, false, "PREREQUISITE_MISSING"), _step("quests.record", {"objective": "brass"}), _step("quests.record", {"objective": "glass"}), _step("quests.record", {"objective": "repair"}), _step("quests.record", {"objective": "beacon"}, {"rewards": 1}), _step("quests.record", {"objective": "beacon"}, {"rewards": 1}), _step("quests.undo", {}, {"rewards": 0}), _step("quests.record", {"objective": "missing"}, {}, false, "UNKNOWN_OBJECTIVE")]
		"LAB-077": return [_step("inventory.commit", {}, {}, false, "NO_CRAFT_PROPOSAL"), _step("inventory.preview", {"recipe": "lantern"}), _step("inventory.commit", {}, {"items": {"glass": 2, "brass": 1, "lantern": 1}, "crafts": 1}), _step("inventory.preview", {"recipe": "glass-lantern"}, {}, false, "MISSING_INGREDIENT"), _step("inventory.undo", {}, {"items": {"glass": 4, "brass": 2, "lantern": 0}})]
		"LAB-078": return [_step("locale.select", {"code": "es"}, {"locale": "es"}), _step("locale.format", {"count": 2}, {"formatted": "2 linternas"}), _step("locale.select", {"code": "ar"}, {"direction": "RTL"}), _step("locale.select", {"code": "missing"}, {}, false, "INVALID_ARGUMENT"), _step("locale.format", {"count": -1}, {}, false, "INVALID_ARGUMENT")]
		"LAB-079": return [_step("focus.navigate", {"direction": "next"}, {"focus": "setting"}), _step("focus.dialog", {"open": true}, {"dialog_depth": 1}), _step("focus.dialog", {"open": true}, {"dialog_depth": 2}), _step("focus.dialog", {"open": true}, {}, false, "DIALOG_DEPTH_LIMIT"), _step("focus.dialog", {"open": false}), _step("focus.dialog", {"open": false}, {"focus": "setting"}), _step("focus.probe"), _step("focus.navigate", {"direction": "sideways"}, {}, false, "INVALID_ARGUMENT")]
		"LAB-080": return [_step("comfort.apply", {"motion": false, "flash": false, "text_scale": 1.4, "assist": true}, {"text_scale": 1.4, "motion": false}), _step("comfort.preview", {}, {"effects": 1}), _step("comfort.apply", {"motion": true, "flash": false, "text_scale": 1.0, "assist": false}, {"motion": true}), _step("comfort.apply", {"motion": false, "flash": false, "text_scale": 4.0, "assist": false}, {}, false, "INVALID_ARGUMENT"), _step("comfort.apply", {"motion": "false", "flash": false, "text_scale": 1.0, "assist": false}, {}, false, "INVALID_ARGUMENT")]
		"LAB-081": return [_step("drag.stage", {"payload": "sea-glass", "target": "material-slot"}, {"assignment": "stone"}), _step("drag.cancel", {}, {"assignment": "stone", "staged": ""}), _step("drag.stage", {"payload": "sea-glass", "target": "material-slot"}), _step("drag.commit", {}, {"assignment": "sea-glass", "commits": 1}), _step("drag.undo", {}, {"assignment": "stone"}), _step("drag.stage", {"payload": "native-file", "target": "material-slot"}, {}, false, "PAYLOAD_TYPE_MISMATCH"), _step("drag.stage", {"payload": "sea-glass", "target": "item-slot"}, {}, false, "INCOMPATIBLE_TARGET")]
	return []

func _limits() -> String:
	return "Original bounded fixtures; source implementation ahead of qualification. Headless state does not qualify pixels, physical input, assistive use or comfort. Dialogue/statechart/quest/craft are lab-owned data contracts. Locale plural examples are a bounded teaching rule. Resource loading accepts only this module's own saved file."
