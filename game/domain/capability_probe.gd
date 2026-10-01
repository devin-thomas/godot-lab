extends RefCounted

const PROFILES: Array[String] = ["CoreLocal", "RenderAdvanced", "NetworkLocal",
	"ProductionTools", "EditorNative", "Web", "Mobile", "XR"]


func capture() -> Dictionary:
	var version: Dictionary = Engine.get_version_info()
	var renderer: String = "unknown"
	if ClassDB.class_has_method("RenderingServer", "get_current_rendering_method"):
		renderer = RenderingServer.get_current_rendering_method()
	var driver: String = "unknown"
	if ClassDB.class_has_method("RenderingServer", "get_current_rendering_driver_name"):
		driver = RenderingServer.get_current_rendering_driver_name()
	var cappy_loaded: bool = _autoload_available("Cappy")
	return {"engine": {"name": "Godot", "version": str(version.get("string", "unknown")),
		"major": int(version.get("major", 0)), "minor": int(version.get("minor", 0)),
		"patch": int(version.get("patch", 0)), "build": str(version.get("hash", "unknown"))},
		"platform": {"os": OS.get_name(), "architecture": Engine.get_architecture_name()},
		"renderer": {"method": renderer, "driver": driver},
		"providers": {"cappy_autoload": cappy_loaded},
		"physical_support": "unverified", "source": "runtime_probe"}


func probe(profile: String = "CoreLocal", providers: Array[String] = []) -> Dictionary:
	var facts: Dictionary = capture()
	if not PROFILES.has(profile):
		return {"ok": false, "code": "unknown_profile", "message": "Capability profile is not defined.",
			"requested_profile": profile, "facts": facts}
	var available: Dictionary = {}
	var missing: Array[String] = []
	for provider: String in providers:
		var present: bool = _provider_available(provider)
		available[provider] = present
		if not present:
			missing.append(provider)
	var fallback: String = ""
	var readiness: String = "ready"
	if profile == "RenderAdvanced":
		if facts["renderer"]["method"] == "gl_compatibility":
			readiness = "fallback"
			fallback = "CoreLocal compatibility-rendered route is available; advanced renderer features are not established."
		else:
			readiness = "unverified"
			fallback = "A renderer name alone does not establish advanced GPU features or performance."
	elif profile == "ProductionTools":
		if providers.is_empty():
			readiness = "unverified"
			fallback = "No production providers were requested; ordinary local play remains available."
		elif missing.size() > 0:
			readiness = "unavailable"
			fallback = "Ordinary local play remains available without the requested production provider."
	elif profile == "EditorNative":
		readiness = "unavailable"
		fallback = "Use the runtime component route; editor/native compilation is not probed here."
	elif profile == "NetworkLocal":
		readiness = "fallback"
		fallback = "No peer transport is started by this probe; offline fixtures remain available."
	elif profile == "Web" or profile == "Mobile" or profile == "XR":
		readiness = "unavailable"
		fallback = "This runtime probe does not qualify exported or physical-device behavior."
	return {"ok": true, "code": "probed", "profile": profile, "readiness": readiness,
		"facts": facts, "provider_checks": available, "missing_providers": missing,
		"fallback": fallback, "physical_support": "unverified"}


func _provider_available(provider: String) -> bool:
	if provider == "Cappy":
		return _autoload_available(provider)
	return Engine.has_singleton(provider)


func _autoload_available(node_name: String) -> bool:
	var main_loop: MainLoop = Engine.get_main_loop()
	if not main_loop is SceneTree:
		return false
	var tree: SceneTree = main_loop
	return tree.root.get_node_or_null(node_name) != null
