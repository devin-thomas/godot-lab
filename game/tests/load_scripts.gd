extends SceneTree


func _initialize() -> void:
	var paths: Array[String] = ["res://main.gd", "res://player.gd", "res://world.gd", "res://lab_store.gd"]
	var success: bool = true
	for path: String in paths:
		var script: GDScript = load(path)
		if script == null or not script.can_instantiate():
			success = false
	print("SCRIPT_GATE " + ("PASS" if success else "FAIL"))
	quit(0 if success else 1)
