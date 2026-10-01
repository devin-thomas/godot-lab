extends RefCounted
## Reusable bounded domains. The museum supplies controls and visualization only.
const Item = preload("res://labs/systems/lab_item.gd")
const Emitter = preload("res://labs/systems/signal_fixture.gd")
var id: String = ""
var state: Dictionary = {}
var revision: int = 0
var history: Array[Dictionary] = []
var request_ledger: Dictionary = {}
var proposals: Dictionary = {}
var storage_namespace: String = "play"
var emitter: Node
var translations: Array[Translation] = []
var previous_locale: String = "en"
var tile_map: TileMapLayer
var tile_body: CharacterBody2D
var item: Resource
var focus_controls: Dictionary = {}
var motion_root: Node3D
var focus_origins: Array[String] = []

func configure(lab_id: String, context: Dictionary = {}) -> void:
	id = lab_id
	storage_namespace = "automation" if bool(context.get("automation", false)) else "play"
	previous_locale = TranslationServer.get_locale()
	reset()
	if id == "LAB-078":
		for code: String in ["en", "es", "ar"]:
			var translation := Translation.new()
			translation.locale = code
			translation.add_message("BEACON_READY", {"en": "Beacon ready", "es": "La linterna del puerto esta preparada", "ar": "\u0627\u0644\u0645\u0646\u0627\u0631\u0629 \u062c\u0627\u0647\u0632\u0629"}[code])
			TranslationServer.add_translation(translation)
			translations.append(translation)
	_restore_preferences()

func reset() -> Dictionary:
	revision = 0
	history.clear()
	request_ledger.clear()
	proposals.clear()
	focus_origins.clear()
	match id:
		"LAB-007": state = {"cells": {"3,2": 1}, "cursor": [1, 2], "collision_hits": 0, "neighbor_edges": 4}
		"LAB-012":
			state = {"binding": "J", "last_device": "keyboard", "invocations": 0}
			_restore_input()
		"LAB-013", "LAB-079": state = {"focus": "confirm", "setting": false, "dialog_depth": 0, "activations": 0, "assistive": "unqualified"}
		"LAB-014": state = {"node": "arrival", "flags": {"helped": false}, "ending": "", "traversals": 0}
		"LAB-018":
			item = _new_item()
			state = {"stable_id": "harbor-lantern", "name": "Harbor lantern", "charge": 3, "saved": false, "reloads": 0, "cache_policy": "CACHE_MODE_IGNORE"}
		"LAB-037": state = {"query": "", "results": [], "probe": {}}
		"LAB-038": state = {"position": 0, "color": "mint", "commits": 0}
		"LAB-039": state = {"active": "stone", "hash": _fixture_json("stone").sha256_text(), "staged": ""}
		"LAB-040":
			state = {"paused": false, "ticks": 0, "distance": 0.0, "job": "running", "generation": 1}
			if is_instance_valid(motion_root): motion_root.process_mode = Node.PROCESS_MODE_INHERIT
		"LAB-041":
			_disconnect_signals()
			state = {"connected": false, "gate": false, "lamp": false, "deliveries": 0, "trace": []}
		"LAB-074": state = {"mode": "idle", "energy": 2, "entries": 0, "exits": 0, "interrupts": 0}
		"LAB-075": state = {"objectives": [], "rewards": 0}
		"LAB-077": state = {"items": {"glass": 4, "brass": 2, "lantern": 0}, "capacity": 8, "crafts": 0}
		"LAB-078":
			state = {"locale": "en", "count": 1, "text": "Beacon ready", "direction": "LTR", "formatted": "1 lantern"}
			TranslationServer.set_locale(previous_locale)
		"LAB-080": state = {"motion": false, "flash": false, "text_scale": 1.0, "assist": false, "effects": 0}
		"LAB-081": state = {"assignment": "stone", "staged": "", "commits": 0}
	_sync_tiles()
	return {"ok": true, "code": "RESET", "revision": revision}

func teardown() -> void:
	_disconnect_signals()
	if id == "LAB-012" and InputMap.has_action("lab_system_interact"):
		InputMap.erase_action("lab_system_interact")
	for translation: Translation in translations:
		TranslationServer.remove_translation(translation)
	translations.clear()
	if id == "LAB-078": TranslationServer.set_locale(previous_locale)
	if is_instance_valid(motion_root): motion_root.process_mode = Node.PROCESS_MODE_INHERIT
	proposals.clear()
	focus_controls.clear()

func operations() -> Array[Dictionary]:
	match id:
		"LAB-007": return [_op("tiles.paint", {"x": _integer(0, 7), "y": _integer(0, 4), "tile": _integer(0, 2)}), _op("tiles.move", {"direction": _enum(["left", "right", "up", "down"])}), _op("tiles.undo")]
		"LAB-012": return [_op("input.bind", {"action": _enum(["interact"]), "key": _enum(["J", "K", "SPACE", "ESCAPE"])}), _op("input.invoke", {"device": _enum(["keyboard", "pad"])}), _op("input.restore_defaults")]
		"LAB-013": return [_op("ui.focus", {"target": _string(32)}), _op("ui.set_setting", {"enabled": _boolean()}), _op("ui.dialog", {"open": _boolean()})]
		"LAB-014": return [_op("dialogue.choose", {"choice": _string(32)}), _op("dialogue.undo")]
		"LAB-018": return [_op("resources.edit", {"name": _string(40), "charge": _integer(0, 9)}), _op("resources.save"), _op("resources.reload")]
		"LAB-037": return [_op("catalog.search", {"query": _string(64)}), _op("catalog.probe", {"id": _string(16)})]
		"LAB-038": return [_op("operations.move", {"position": _integer(-3, 3), "request": _string(32), "expected_revision": _integer(0, 100000)}), _op("operations.undo")]
		"LAB-039": return [_op("fixtures.stage", {"fixture": _string(64)}), _op("fixtures.commit"), _op("fixtures.cancel")]
		"LAB-040": return [_op("lifecycle.pause"), _op("lifecycle.resume"), _op("lifecycle.step", {"ticks": _integer(1, 60)}), _op("lifecycle.cancel")]
		"LAB-041": return [_op("signals.connect_route"), _op("signals.emit_event", {"source": _enum(["lever", "bell"])}), _op("signals.disconnect")]
		"LAB-074": return [_op("statechart.event", {"event": _string(32)})]
		"LAB-075": return [_op("quests.record", {"objective": _string(32)}), _op("quests.undo")]
		"LAB-077": return [_op("inventory.preview", {"recipe": _string(32)}), _op("inventory.commit"), _op("inventory.undo")]
		"LAB-078": return [_op("locale.select", {"code": _enum(["en", "es", "ar"])}), _op("locale.format", {"count": _integer(0, 99)})]
		"LAB-079": return [_op("focus.navigate", {"direction": _enum(["next", "previous"])}), _op("focus.dialog", {"open": _boolean()}), _op("focus.probe")]
		"LAB-080": return [_op("comfort.apply", {"motion": _boolean(), "flash": _boolean(), "text_scale": {"type": "number", "min": 0.8, "max": 1.8}, "assist": _boolean()}), _op("comfort.preview")]
		"LAB-081": return [_op("drag.stage", {"payload": _string(32), "target": _string(32)}), _op("drag.commit"), _op("drag.cancel"), _op("drag.undo")]
	return []

func apply_operation(name: String, args: Dictionary) -> Dictionary:
	var valid: Dictionary = _validate(name, args)
	if not bool(valid.ok): return valid
	var before: Dictionary = state.duplicate(true)
	var result: Dictionary = _dispatch(name, args)
	if bool(result.get("ok", false)) and state != before:
		revision += 1
	result["revision"] = revision
	return result

func observe() -> Dictionary:
	var snapshot: Dictionary = state.duplicate(true)
	snapshot["revision"] = revision
	snapshot["undo_depth"] = history.size()
	snapshot["proposal_count"] = proposals.size()
	if id == "LAB-007" and is_instance_valid(tile_map):
		snapshot["tile_cells"] = tile_map.get_used_cells().size()
		snapshot["physics_layers"] = tile_map.tile_set.get_physics_layers_count()
	if id == "LAB-018" and item != null: snapshot["resource_class"] = item.get_script().resource_path
	if id == "LAB-012": snapshot["inputmap_events"] = InputMap.action_get_events("lab_system_interact").size()
	if id in ["LAB-013", "LAB-079"] and not focus_controls.is_empty():
		var owner: Control = focus_controls.values()[0].get_viewport().gui_get_focus_owner()
		snapshot["godot_focus"] = owner.name if owner != null else "none"
	return snapshot

func _dispatch(name: String, args: Dictionary) -> Dictionary:
	match name:
		"tiles.paint":
			var key: String = "%s,%s" % [args.x, args.y]
			_push_history()
			state.cells[key] = int(args.tile)
			_sync_tiles()
			return _ok({"cell": key, "tile": args.tile})
		"tiles.move":
			var offsets: Dictionary = {"left": Vector2i(-1, 0), "right": Vector2i(1, 0), "up": Vector2i(0, -1), "down": Vector2i(0, 1)}
			var target: Vector2i = Vector2i(int(state.cursor[0]), int(state.cursor[1])) + offsets[args.direction]
			if target.x < 0 or target.x > 7 or target.y < 0 or target.y > 4: return _fail("ROOM_BOUNDARY")
			if int(state.cells.get("%s,%s" % [target.x, target.y], 0)) == 1:
				return _fail("SOLID_TILE", {"collision_layer": 1})
			if is_instance_valid(tile_body):
				var delta: Vector2 = Vector2(target - Vector2i(int(state.cursor[0]), int(state.cursor[1]))) * 32.0
				var collision: KinematicCollision2D = tile_body.move_and_collide(delta)
				if collision != null: return _fail("PHYSICS_COLLISION")
			state.cursor = [target.x, target.y]
			return _ok({"cell": state.cursor})
		"tiles.undo", "dialogue.undo", "operations.undo", "quests.undo", "inventory.undo", "drag.undo": return _undo()
		"input.bind":
			if args.key in ["ESCAPE", "SPACE"]: return _fail("ESSENTIAL_BINDING_CONFLICT")
			state.binding = args.key
			_restore_input()
			return _ok({"prompt": args.key})
		"input.restore_defaults":
			state.binding = "J"
			state.last_device = "keyboard"
			_restore_input()
			return _ok()
		"input.invoke":
			var event: InputEvent
			if args.device == "keyboard":
				var key_event := InputEventKey.new()
				key_event.physical_keycode = KEY_J if state.binding == "J" else KEY_K
				key_event.pressed = true
				event = key_event
			else:
				var pad_event := InputEventJoypadButton.new()
				pad_event.button_index = JOY_BUTTON_A
				pad_event.pressed = true
				event = pad_event
			if not event.is_action_pressed("lab_system_interact"): return _fail("BINDING_NOT_DISPATCHED")
			state.invocations += 1
			state.last_device = args.device
			return _ok({"event_type": event.get_class()})
		"ui.focus": return _focus(String(args.target))
		"ui.set_setting":
			state.setting = args.enabled
			state.activations += 1
			return _ok()
		"ui.dialog", "focus.dialog":
			if bool(args.open):
				if focus_origins.size() >= 2: return _fail("DIALOG_DEPTH_LIMIT")
				focus_origins.append(String(state.focus))
				state.dialog_depth = focus_origins.size()
				return _focus("close")
			if focus_origins.is_empty(): return _fail("NO_OPEN_DIALOG")
			var origin: String = focus_origins.pop_back()
			state.dialog_depth = focus_origins.size()
			return _focus(origin)
		"dialogue.choose": return _choose(String(args.choice))
		"resources.edit":
			if String(args.name).is_empty(): return _fail("EMPTY_NAME")
			item.display_name = String(args.name)
			item.charge = int(args.charge)
			state.name = args.name
			state.charge = args.charge
			return _ok()
		"resources.save":
			if not item.validated(): return _fail("INVALID_RESOURCE")
			var error: Error = DirAccess.make_dir_recursive_absolute("user://godot-lab/systems")
			if error != OK: return _fail("DIRECTORY_WRITE_FAILED", {"error": error})
			error = ResourceSaver.save(item, _resource_path())
			if error != OK: return _fail("RESOURCE_SAVE_FAILED", {"error": error})
			state.saved = true
			return _ok({"identity": item.stable_id, "storage_namespace": storage_namespace})
		"resources.reload":
			if not FileAccess.file_exists(_resource_path()): return _fail("RESOURCE_NOT_SAVED")
			var loaded: Resource = ResourceLoader.load(_resource_path(), "", ResourceLoader.CACHE_MODE_IGNORE)
			if loaded == null or loaded.get_script() != Item or not loaded.validated(): return _fail("RESOURCE_VALIDATION_FAILED")
			item = loaded
			state.name = item.display_name
			state.charge = item.charge
			state.reloads += 1
			return _ok({"identity": item.stable_id, "charge": item.charge})
		"catalog.search":
			var query: String = String(args.query).to_lower()
			state.query = query
			state.results = []
			for card: Dictionary in _catalog():
				if query.is_empty() or String(card.title + " " + card.payoff).to_lower().contains(query): state.results.append(card.id)
			return _ok({"results": state.results.duplicate()})
		"catalog.probe":
			for card: Dictionary in _catalog():
				if card.id == args.id:
					state.probe = card.duplicate(true)
					state.probe["engine"] = Engine.get_version_info().string
					return _ok({"probe": state.probe})
			return _fail("LAB_NOT_FOUND")
		"operations.move": return _move(args)
		"fixtures.stage":
			var fixture: String = String(args.fixture)
			if fixture.contains("/") or fixture.contains("\\") or fixture.contains(".."): return _fail("EXTERNAL_PATH_REJECTED")
			if fixture == "oversized": return _fail("FIXTURE_SIZE_LIMIT")
			if fixture not in ["stone", "mint", "brass"]: return _fail("FIXTURE_NOT_FOUND")
			var source: String = _fixture_json(fixture)
			var parsed: Variant = JSON.parse_string(source)
			if not parsed is Dictionary or parsed.get("schema") != 1: return _fail("FIXTURE_SCHEMA")
			proposals = {"fixture": fixture, "hash": source.sha256_text(), "bytes": source.to_utf8_buffer().size(), "license": "original-project"}
			state.staged = fixture
			return _ok({"proposal": proposals.duplicate(true)})
		"fixtures.commit":
			if proposals.is_empty(): return _fail("NO_STAGED_FIXTURE")
			state.active = proposals.fixture
			state.hash = proposals.hash
			state.staged = ""
			proposals.clear()
			return _ok({"hash": state.hash})
		"fixtures.cancel", "drag.cancel":
			proposals.clear()
			state.staged = ""
			return _ok({"cancelled": true})
		"lifecycle.pause":
			state.paused = true
			if is_instance_valid(motion_root): motion_root.process_mode = Node.PROCESS_MODE_DISABLED
			return _ok()
		"lifecycle.resume":
			if state.job == "cancelled": return _fail("JOB_CANCELLED")
			state.paused = false
			if is_instance_valid(motion_root): motion_root.process_mode = Node.PROCESS_MODE_INHERIT
			return _ok()
		"lifecycle.step":
			if state.paused: return _fail("SIMULATION_PAUSED")
			if state.job == "cancelled": return _fail("JOB_CANCELLED")
			state.ticks += int(args.ticks)
			state.distance = float(state.ticks) / 60.0
			if state.ticks >= 180: state.job = "completed"
			return _ok({"ticks": state.ticks})
		"lifecycle.cancel":
			state.job = "cancelled"
			state.generation += 1
			return _ok({"cancelled_generation": state.generation - 1})
		"signals.connect_route":
			if not is_instance_valid(emitter): return _fail("EMITTER_UNAVAILABLE")
			if not emitter.pulse.is_connected(_receive_pulse): emitter.pulse.connect(_receive_pulse)
			state.connected = true
			return _ok({"connections": emitter.pulse.get_connections().size()})
		"signals.disconnect":
			_disconnect_signals()
			state.connected = false
			return _ok()
		"signals.emit_event":
			if not is_instance_valid(emitter): return _fail("EMITTER_UNAVAILABLE")
			emitter.trigger(String(args.source))
			return _ok({"sequence": emitter.sequence, "delivered": state.connected})
		"statechart.event": return _transition(String(args.event))
		"quests.record": return _quest(String(args.objective))
		"inventory.preview": return _craft_preview(String(args.recipe))
		"inventory.commit":
			if proposals.is_empty(): return _fail("NO_CRAFT_PROPOSAL")
			if int(proposals.revision) != revision: return _fail("STALE_PROPOSAL")
			_push_history()
			state.items = proposals.result.duplicate(true)
			state.crafts += 1
			proposals.clear()
			return _ok({"items": state.items.duplicate(true)})
		"locale.select":
			var saved: Dictionary = _save_preferences({"locale": args.code})
			if not bool(saved.ok): return saved
			TranslationServer.set_locale(String(args.code))
			state.locale = args.code
			state.text = TranslationServer.translate("BEACON_READY")
			state.direction = "RTL" if args.code == "ar" else "LTR"
			return _ok({"text": state.text})
		"locale.format":
			state.count = int(args.count)
			var suffix: String = "lantern" if int(args.count) == 1 else "lanterns"
			if state.locale == "es": suffix = "linterna" if int(args.count) == 1 else "linternas"
			if state.locale == "ar": suffix = "\u0645\u0646\u0627\u0631\u0629" if int(args.count) == 1 else "\u0645\u0646\u0627\u0631\u0627\u062a"
			state.formatted = "%s %s" % [args.count, suffix]
			return _ok({"text": state.formatted, "rule": "fixture singular=1; plural=other, not CLDR qualification"})
		"focus.navigate":
			if int(state.dialog_depth) > 0: return _focus("close")
			var targets: Array[String] = ["confirm", "setting", "dialog"]
			var index: int = targets.find(String(state.focus))
			index = posmod(index + (1 if args.direction == "next" else -1), targets.size())
			return _focus(targets[index])
		"focus.probe":
			state.assistive = "API probe only; screen-reader route unqualified"
			return _ok({"keyboard_focus": true, "screen_reader_verified": false, "control_accessibility_property": ClassDB.class_has_method("Control", "get_accessibility_name")})
		"comfort.apply":
			var saved: Dictionary = _save_preferences(args)
			if not bool(saved.ok): return saved
			state.motion = args.motion
			state.flash = args.flash
			state.text_scale = float(args.text_scale)
			state.assist = args.assist
			return _ok({"safe_default": not state.motion and not state.flash})
		"comfort.preview":
			state.effects += 1
			return _ok({"motion_enabled": state.motion, "flash_enabled": state.flash, "duration_seconds": 0.3})
		"drag.stage":
			if args.payload != "sea-glass": return _fail("PAYLOAD_TYPE_MISMATCH")
			if args.target != "material-slot": return _fail("INCOMPATIBLE_TARGET")
			proposals = {"payload": args.payload, "target": args.target, "revision": revision + (0 if state.staged == args.payload else 1)}
			state.staged = args.payload
			return _ok({"proposal": proposals.duplicate(true)})
		"drag.commit":
			if proposals.is_empty(): return _fail("NO_DROP_PROPOSAL")
			if int(proposals.revision) != revision: return _fail("STALE_PROPOSAL")
			_push_history()
			state.assignment = proposals.payload
			state.staged = ""
			state.commits += 1
			proposals.clear()
			return _ok()
	return _fail("UNKNOWN_OPERATION")

func _choose(choice: String) -> Dictionary:
	if int(state.traversals) >= 12: return _fail("TRAVERSAL_LIMIT")
	var graph: Dictionary = {
		"arrival": {"help": "repair", "leave": "farewell", "secret": "tower"},
		"repair": {"light": "beacon", "return": "arrival"},
		"beacon": {"sail": "harbor", "return": "repair"},
		"harbor": {"listen": "keeper", "sail": "voyage"},
		"keeper": {"promise": "promise", "return": "harbor"},
		"promise": {"depart": "voyage"},
		"farewell": {"depart": "storm", "return": "arrival"},
		"storm": {"shelter": "tower", "sail": "lost"},
		"tower": {"wait": "dawn", "return": "arrival"},
		"dawn": {"sail": "voyage"}, "voyage": {}, "lost": {}}
	var available: Dictionary = graph[String(state.node)]
	if not available.has(choice): return _fail("CHOICE_NOT_AVAILABLE")
	if choice == "secret" and not bool(state.flags.helped): return _fail("BRANCH_GUARD")
	_push_history()
	state.node = available[choice]
	state.traversals += 1
	if choice == "help": state.flags.helped = true
	if state.node in ["voyage", "lost"]: state.ending = state.node
	return _ok({"node": state.node, "flags": state.flags.duplicate()})

func _move(args: Dictionary) -> Dictionary:
	var request: String = String(args.request)
	if request.is_empty(): return _fail("EMPTY_REQUEST_ID")
	var payload: String = JSON.stringify(args, "", true)
	if request_ledger.has(request):
		var prior: Dictionary = request_ledger[request]
		return _ok({"duplicate": true}) if prior.payload == payload else _fail("REQUEST_ID_REUSED")
	if request_ledger.size() >= 64: return _fail("LEDGER_CAPACITY")
	if int(args.expected_revision) != revision: return _fail("REVISION_CONFLICT", {"current_revision": revision})
	_push_history()
	state.position = int(args.position)
	state.commits += 1
	request_ledger[request] = {"payload": payload}
	return _ok({"duplicate": false, "position": state.position})

func _transition(event: String) -> Dictionary:
	var transitions: Dictionary = {"idle": {"start": "walking"}, "walking": {"jump": "airborne", "stop": "idle", "interrupt": "idle"}, "airborne": {"land": "idle", "interrupt": "idle"}}
	if not transitions[String(state.mode)].has(event): return _fail("TRANSITION_NOT_ALLOWED")
	if event == "jump" and int(state.energy) <= 0: return _fail("ENERGY_GUARD")
	state.exits += 1
	state.mode = transitions[String(state.mode)][event]
	state.entries += 1
	if event == "jump": state.energy -= 1
	if event == "interrupt": state.interrupts += 1
	return _ok({"mode": state.mode, "hooks": ["exit", "entry"]})

func _quest(objective: String) -> Dictionary:
	var prerequisites: Dictionary = {"glass": [], "brass": [], "repair": ["glass", "brass"], "beacon": ["repair"], "flowers": []}
	if not prerequisites.has(objective): return _fail("UNKNOWN_OBJECTIVE")
	if objective in state.objectives: return _ok({"duplicate": true})
	for needed: String in prerequisites[objective]:
		if needed not in state.objectives: return _fail("PREREQUISITE_MISSING", {"required": needed})
	_push_history()
	state.objectives.append(objective)
	if objective == "beacon": state.rewards += 1
	return _ok({"objective": objective, "complete": "beacon" in state.objectives})

func _craft_preview(recipe: String) -> Dictionary:
	var recipes: Dictionary = {"lantern": {"glass": 2, "brass": 1}, "glass-lantern": {"glass": 3}, "brass-lantern": {"brass": 2}}
	if not recipes.has(recipe): return _fail("UNKNOWN_RECIPE")
	var after: Dictionary = state.items.duplicate(true)
	for ingredient: String in recipes[recipe]:
		var count: int = int(recipes[recipe][ingredient])
		if int(after[ingredient]) < count: return _fail("MISSING_INGREDIENT", {"ingredient": ingredient})
		after[ingredient] -= count
	if int(after.lantern) >= 2: return _fail("SLOT_CAPACITY")
	after.lantern += 1
	var total: int = 0
	for count: Variant in after.values(): total += int(count)
	if total > int(state.capacity): return _fail("INVENTORY_CAPACITY")
	proposals = {"recipe": recipe, "result": after, "revision": revision + (0 if state.get("preview") == recipe else 1)}
	# Preview has its own visible identity; commit checks that exact revision.
	state["preview"] = recipe
	return _ok({"cost": recipes[recipe], "result": after})

func _focus(target: String) -> Dictionary:
	if target not in ["confirm", "setting", "dialog", "close"]: return _fail("FOCUS_TARGET_MISSING")
	if target == "close" and int(state.dialog_depth) == 0: return _fail("HIDDEN_CONTROL")
	if focus_controls.has(target):
		var control: Control = focus_controls[target]
		if not is_instance_valid(control): return _fail("FOCUS_TARGET_REMOVED")
		control.visible = true
		control.grab_focus()
	state.focus = target
	return _ok({"target": target})

func _push_history() -> void:
	if history.size() >= 32: history.pop_front()
	history.append(state.duplicate(true))

func _undo() -> Dictionary:
	if history.is_empty(): return _fail("UNDO_EMPTY")
	state = history.pop_back()
	proposals.clear()
	_sync_tiles()
	return _ok({"restored": true})

func _restore_input() -> void:
	if not InputMap.has_action("lab_system_interact"): InputMap.add_action("lab_system_interact")
	InputMap.action_erase_events("lab_system_interact")
	var key := InputEventKey.new()
	key.physical_keycode = KEY_J if state.get("binding", "J") == "J" else KEY_K
	InputMap.action_add_event("lab_system_interact", key)
	var pad := InputEventJoypadButton.new()
	pad.button_index = JOY_BUTTON_A
	InputMap.action_add_event("lab_system_interact", pad)

func _new_item() -> Resource:
	var resource := Item.new()
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color("234d5c"), Color("e5ba63")])
	resource.surface = GradientTexture2D.new()
	resource.surface.gradient = gradient
	resource.surface.width = 16
	resource.surface.height = 16
	return resource

func _resource_path() -> String:
	return "user://godot-lab/systems/%s-%s.tres" % [storage_namespace, id.to_lower()]

func _preference_path() -> String:
	return "user://godot-lab/systems/%s-%s-preferences.json" % [storage_namespace, id.to_lower()]

func _save_preferences(values: Dictionary) -> Dictionary:
	var error: Error = DirAccess.make_dir_recursive_absolute("user://godot-lab/systems")
	if error != OK: return _fail("DIRECTORY_WRITE_FAILED", {"error": error})
	var temporary: String = _preference_path() + ".pending"
	var file: FileAccess = FileAccess.open(temporary, FileAccess.WRITE)
	if file == null: return _fail("PREFERENCE_WRITE_FAILED", {"error": FileAccess.get_open_error()})
	file.store_string(JSON.stringify({"schema": 1, "lab": id, "values": values}, "", true))
	file.flush()
	error = file.get_error()
	file.close()
	if error != OK: return _fail("PREFERENCE_WRITE_FAILED", {"error": error})
	error = DirAccess.rename_absolute(temporary, _preference_path())
	if error != OK: return _fail("PREFERENCE_PUBLISH_FAILED", {"error": error})
	return _ok({"persisted": true})

func _restore_preferences() -> void:
	if id not in ["LAB-078", "LAB-080"] or not FileAccess.file_exists(_preference_path()): return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(_preference_path()))
	if not parsed is Dictionary or parsed.get("schema") != 1 or parsed.get("lab") != id or not parsed.get("values") is Dictionary:
		state["preference_error"] = "UNSUPPORTED_PREFERENCE_DOCUMENT"
		return
	var values: Dictionary = parsed.values
	var name: String = "locale.select" if id == "LAB-078" else "comfort.apply"
	var valid: Dictionary = _validate(name, {"code": values.get("locale")} if id == "LAB-078" else values)
	if not bool(valid.ok):
		state["preference_error"] = "INVALID_PREFERENCE_VALUES"
		return
	if id == "LAB-078":
		state.locale = values.locale
		TranslationServer.set_locale(String(values.locale))
		state.text = TranslationServer.translate("BEACON_READY")
		state.direction = "RTL" if values.locale == "ar" else "LTR"
	else:
		state.merge(values, true)
	state["preferences_restored"] = true

func _fixture_json(fixture: String) -> String:
	return JSON.stringify({"schema": 1, "id": fixture, "license": "original-project", "size": [1, 1, 1], "color": fixture}, "", true)

func _catalog() -> Array[Dictionary]:
	return [{"id": "LAB-007", "title": "Tile Workshop", "payoff": "paint a room", "ready": ClassDB.class_exists("TileMapLayer"), "reason": "installed TileMapLayer API", "route": "CoreLocal"}, {"id": "LAB-018", "title": "Resource Cabinet", "payoff": "save lantern resources", "ready": ClassDB.class_exists("ResourceSaver"), "reason": "installed ResourceSaver API", "route": "CoreLocal"}, {"id": "LAB-092", "title": "XR Observatory", "payoff": "spatial headset", "ready": false, "reason": "XR runtime and physical headset unqualified", "route": "specified"}]

func _receive_pulse(source: String, sequence: int) -> void:
	state.deliveries += 1
	state.gate = not bool(state.gate)
	state.lamp = state.gate
	if state.trace.size() >= 32: state.trace.pop_front()
	state.trace.append({"source": source, "sequence": sequence})

func _disconnect_signals() -> void:
	if is_instance_valid(emitter) and emitter.pulse.is_connected(_receive_pulse): emitter.pulse.disconnect(_receive_pulse)

func _sync_tiles() -> void:
	if id != "LAB-007": return
	var edges: int = 0
	for key: String in state.cells:
		if int(state.cells[key]) != 1: continue
		var parts: PackedStringArray = key.split(",")
		var at := Vector2i(int(parts[0]), int(parts[1]))
		for offset: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var adjacent: Vector2i = at + offset
			if int(state.cells.get("%s,%s" % [adjacent.x, adjacent.y], 0)) != 1: edges += 1
	state.neighbor_edges = edges
	if not is_instance_valid(tile_map): return
	for x: int in range(8):
		for y: int in range(5):
			var tile: int = int(state.cells.get("%s,%s" % [x, y], 0))
			var atlas_x: int = 0
			if tile == 2: atlas_x = 17
			elif tile == 1:
				atlas_x = 1
				var offsets: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
				for index: int in range(offsets.size()):
					var adjacent: Vector2i = Vector2i(x, y) + offsets[index]
					if int(state.cells.get("%s,%s" % [adjacent.x, adjacent.y], 0)) == 1: atlas_x += 1 << index
			tile_map.set_cell(Vector2i(x, y), 0, Vector2i(atlas_x, 0))
	tile_map.update_internals()
	if is_instance_valid(tile_body): tile_body.position = Vector2(float(state.cursor[0]) * 32.0 + 16.0, float(state.cursor[1]) * 32.0 + 16.0)

func _op(name: String, arguments: Dictionary = {}) -> Dictionary:
	return {"name": name, "scope": "lab", "arguments": arguments, "required": arguments.keys(), "mutates": true}

func _integer(low: int, high: int) -> Dictionary: return {"type": "integer", "min": low, "max": high}
func _enum(values: Array) -> Dictionary: return {"type": "enum", "values": values}
func _string(length: int) -> Dictionary: return {"type": "string", "max_length": length}
func _boolean() -> Dictionary: return {"type": "boolean"}
func _ok(extra: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {"ok": true, "code": "APPLIED"}
	result.merge(extra)
	return result
func _fail(code: String, extra: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {"ok": false, "code": code, "revision": revision}
	result.merge(extra)
	return result

func _validate(name: String, args: Dictionary) -> Dictionary:
	var descriptor: Dictionary = {}
	for entry: Dictionary in operations():
		if entry.name == name: descriptor = entry
	if descriptor.is_empty(): return _fail("UNKNOWN_OPERATION")
	var schemas: Dictionary = descriptor.arguments
	if args.size() != schemas.size(): return _fail("INVALID_ARGUMENT_FIELDS")
	for key: String in schemas:
		if not args.has(key): return _fail("MISSING_ARGUMENT")
		var value: Variant = args[key]
		var rule: Dictionary = schemas[key]
		match String(rule.type):
			"integer":
				if not value is int or int(value) < int(rule.min) or int(value) > int(rule.max): return _fail("INVALID_ARGUMENT")
			"number":
				if (not value is float and not value is int) or not is_finite(float(value)) or float(value) < float(rule.min) or float(value) > float(rule.max): return _fail("INVALID_ARGUMENT")
			"string":
				if not value is String or String(value).length() > int(rule.max_length): return _fail("INVALID_ARGUMENT")
			"enum":
				if not value is String or value not in rule.values: return _fail("INVALID_ARGUMENT")
			"boolean":
				if not value is bool: return _fail("INVALID_ARGUMENT")
	return _ok()
