extends RefCounted

const SYSTEM_IDS: Array[String] = ["LAB-007", "LAB-012", "LAB-013", "LAB-014", "LAB-018",
	"LAB-037", "LAB-038", "LAB-039", "LAB-040", "LAB-041", "LAB-074", "LAB-075",
	"LAB-077", "LAB-078", "LAB-079", "LAB-080", "LAB-081"]
const VISUAL_IDS: Array[String] = ["LAB-008", "LAB-009", "LAB-011", "LAB-016", "LAB-017", "LAB-019",
	"LAB-023", "LAB-055", "LAB-060", "LAB-061", "LAB-066", "LAB-068"]
const DATA_IDS: Array[String] = ["LAB-025", "LAB-028", "LAB-036", "LAB-089", "LAB-091", "LAB-092"]
const BASELINE: Dictionary = {"LAB-001": "motion", "LAB-002": "physics", "LAB-003": "navigation",
	"LAB-004": "materials", "LAB-005": "audio", "LAB-006": "persistence"}
var entries: Array[Dictionary] = []
var error: String = ""


func load_catalog() -> bool:
	var file: FileAccess = FileAccess.open("res://labs/catalog.json", FileAccess.READ)
	if file == null:
		error = "Catalog cannot be opened: %s" % FileAccess.get_open_error()
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Array or parsed.size() != 96:
		error = "Expected the 96-lab catalog"
		return false
	entries.clear()
	for entry: Variant in parsed:
		if not entry is Dictionary or not entry.has_all(["id", "title", "wing", "payoff", "limits"]):
			error = "Invalid catalog entry"
			return false
		entries.append(entry.duplicate(true))
	return true


func playable_ids() -> Array[String]:
	var result: Array[String] = []
	for id: String in BASELINE:
		result.append(BASELINE[id])
	result.append_array(module_ids())
	return result


func module_ids() -> Array[String]:
	var result: Array[String] = []
	result.append_array(SYSTEM_IDS)
	result.append_array(VISUAL_IDS)
	result.append_array(DATA_IDS)
	return result


func route(id: String) -> String:
	return BASELINE.get(id, id)


func available(id: String) -> bool:
	return BASELINE.has(id) or module_ids().has(id)


func instantiate(id: String) -> Node3D:
	if not module_ids().has(id):
		return null
	var path: String = "res://labs/modules/system_labs.gd" if SYSTEM_IDS.has(id) else "res://labs/modules/visual_labs.gd" if VISUAL_IDS.has(id) else "res://labs/modules/data_labs.gd"
	var script: GDScript = load(path)
	if script == null or not script.can_instantiate():
		error = "System module failed to load"
		return null
	var module: Node3D = script.new()
	module.lab_id = id
	return module


func search(query: String, wing: String = "all") -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var needle: String = query.strip_edges().to_lower()
	for entry: Dictionary in entries:
		if wing != "all" and entry["wing"] != wing:
			continue
		var haystack: String = "%s %s %s %s" % [entry["id"], entry["title"], entry["wing"], entry["payoff"]]
		if needle.is_empty() or haystack.to_lower().contains(needle):
			results.append(entry.duplicate(true))
	return results
