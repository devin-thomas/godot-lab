extends "res://labs/lab_module.gd"

const DocumentStoreScript: GDScript = preload("res://domain/document_store.gd")
const FixtureRegistryScript: GDScript = preload("res://domain/fixture_registry.gd")
const JobRegistryScript: GDScript = preload("res://domain/job_registry.gd")
const CapabilityProbeScript: GDScript = preload("res://domain/capability_probe.gd")
const SimulationRecordScript: GDScript = preload("res://domain/simulation_record.gd")
const WorkerCoordinatorScript: GDScript = preload("res://labs/data/worker_coordinator.gd")
const GoldenComparatorScript: GDScript = preload("res://labs/data/golden_comparator.gd")
const FINGERPRINT_MANIFEST: String = "res://labs/data/data_labs_fingerprint.json"

const TITLES: Dictionary = {
	"LAB-025": "Replay Observatory", "LAB-028": "Thread Mill", "LAB-036": "Profiling Booth",
	"LAB-089": "Parameter Sweeps", "LAB-091": "Golden Assertions", "LAB-092": "Memory Observatory"}
const EXPLANATIONS: Dictionary = {
	"LAB-025": "Record ordered fixture operations to a versioned file, reset the specimen, then replay the same actions against an isolated copy.",
	"LAB-028": "Send a bounded integer fixture to WorkerThreadPool. The worker only returns data; progress, cancellation and scene-facing state stay on the main thread.",
	"LAB-036": "Warm a fixed script workload, sample measured durations, and compare baseline with a cheaper workload while the visible specimen stays fixed.",
	"LAB-089": "Plan at most eight original parameter rows, run local measurements, cancel at a row boundary, and resume only rows with saved results. Cappy capture is unqualified.",
	"LAB-091": "Compare actual generated image regions, PCM fixture bytes and semantic dictionaries. A reference changes only after an explicit review choice.",
	"LAB-092": "Create and release real MeshInstances and Mesh resources, inspect engine object counters, cap retained cache entries and detect a deliberate leak."}

var lab_id: String = "LAB-025"
var _state: Dictionary = {}
var _source_fingerprint: String = ""
var _source_fingerprint_verified: bool = false
var _source_fingerprint_status: String = "unavailable"
var _fixture_hash: String = ""
var _fixture: RefCounted
var _document_store: RefCounted
var _job_registry: RefCounted
var _capability_probe: RefCounted
var _worker: RefCounted
var _goldens: RefCounted
var _timeline: RefCounted
var _timeline_context: Dictionary = {}
var _timeline_revision: int = 0
var _profile_reports: Dictionary = {}
var _active_job_id: String = ""
var _sweep_proposal: Dictionary = {}
var _memory_cache: Array[Mesh] = []
var _intentional_leak: MeshInstance3D
var _readout: RichTextLabel
var _display_blocks: Array[MeshInstance3D] = []
var _golden_available: bool = true
var _last_golden_candidate: Dictionary = {}


func setup(context: Dictionary) -> void:
	super.setup(context)
	module_revision = 0
	var fingerprint_result: Dictionary = _load_source_fingerprint()
	_source_fingerprint = str(fingerprint_result.get("fingerprint", ""))
	_source_fingerprint_verified = bool(fingerprint_result.get("verified", false))
	_source_fingerprint_status = str(fingerprint_result.get("status", "unavailable"))
	_fixture = FixtureRegistryScript.new()
	_fixture.configure("fixture-" + lab_id.to_lower())
	var fixture_text: String = JSON.stringify({"schema_version": 1, "lab": lab_id,
		"seed": 1701, "recipe": "original-local-data-fixture"})
	var fixture_result: Dictionary = _fixture.register_fixture("sample", {"payload": fixture_text,
		"source": "Original Signal Observatory fixture", "license": "CC0-1.0", "version": 1})
	if not fixture_result.get("ok", false):
		push_error("Data lab fixture registration failed: " + str(fixture_result.get("code", "UNKNOWN")))
	_fixture_hash = str(fixture_result.get("manifest", {}).get("sha256", ""))
	_capability_probe = CapabilityProbeScript.new()
	_state = {"ready": not _fixture_hash.is_empty(), "revision": 0, "fixture_hash": _fixture_hash,
		"source_fingerprint": _source_fingerprint, "last_code": "READY", "recording": false,
		"source_fingerprint_verified": _source_fingerprint_verified,
		"source_fingerprint_status": _source_fingerprint_status,
		"reference_available": true, "fixture_x": 0, "fixture_y": 0}
	_build_exhibit()
	_setup_service()
	_sync_visuals()


func describe() -> Dictionary:
	var ready: bool = bool(_state.get("ready", false)) and not _source_fingerprint.is_empty()
	var limit_text: String = _limits()
	if lab_id == "LAB-089":
		limit_text += " Cappy provider capture is explicitly unqualified; sweep rows use local computation only."
	return {"id": lab_id, "title": TITLES.get(lab_id, "Data lab"),
		"description": EXPLANATIONS.get(lab_id, ""), "action": _action_label(),
		"ready": ready, "readiness": _readiness(), "limits": limit_text,
		"source_fingerprint": _source_fingerprint,
		"source_fingerprint_verified": _source_fingerprint_verified,
		"source_fingerprint_status": _source_fingerprint_status}


func operations() -> Array[Dictionary]:
	match lab_id:
		"LAB-025": return [
			_descriptor("replay.record", {"duration_ticks": _integer_rule(1, 60)}, ["duration_ticks"], true),
			_descriptor("replay.action", {"direction": _enum_rule(["east", "west", "north", "south"])}, ["direction"], true),
			_descriptor("replay.play", {"timeline_id": _string_rule(64), "fingerprint": _string_rule(64),
				"version": _integer_rule(1, 999), "expected_revision": _integer_rule(0, 2147483647)},
				["timeline_id", "fingerprint", "version"], false)]
		"LAB-028": return [
			_descriptor("jobs.start", {"seed": _integer_rule(0, 9999), "elements": _integer_rule(64, 4096)},
				["seed", "elements"], true),
			_descriptor("jobs.poll", {}, [], true),
			_descriptor("jobs.cancel", {"job_id": _string_rule(128)}, ["job_id"], true)]
		"LAB-036": return [
			_descriptor("profiling.run", {"workload": _enum_rule(["baseline", "optimized"]),
				"sample_count": _integer_rule(3, 32), "warm_up": _integer_rule(1, 16)},
				["workload", "sample_count", "warm_up"], true),
			_descriptor("profiling.compare", {"a": _string_rule(64), "b": _string_rule(64)},
				["a", "b"], false)]
		"LAB-089": return [
			_descriptor("sweeps.plan", {"start": _integer_rule(1, 8), "end": _integer_rule(1, 8),
				"step": _integer_rule(1, 4)}, ["start", "end", "step"], true),
			_descriptor("sweeps.run", {"proposal_id": _string_rule(64), "fingerprint": _string_rule(64),
				"cancel_after": _integer_rule(0, 8)}, ["proposal_id", "fingerprint"], true),
			_descriptor("sweeps.observe", {}, [], false)]
		"LAB-091": return [
			_descriptor("goldens.compare", {"channel": _enum_rule(["image", "audio", "state"]),
				"variant": _enum_rule(["baseline", "mutated", "muted", "wrong_tone"]),
				"tolerance": {"type": "number", "min": 0.0, "max": 1.0},
				"fingerprint": _string_rule(64)}, ["channel", "variant", "tolerance", "fingerprint"], false),
			_descriptor("goldens.drop_reference", {}, [], true),
			_descriptor("goldens.propose_update", {"run_id": _string_rule(64), "channel": _enum_rule(["image", "audio", "state"]),
				"variant": _enum_rule(["baseline", "mutated", "muted", "wrong_tone"]),
				"reviewed": {"type": "boolean"}}, ["run_id", "channel", "variant", "reviewed"], true)]
		"LAB-092": return [
			_descriptor("memory.run_cycles", {"cycles": _integer_rule(1, 8),
				"objects_per_cycle": _integer_rule(1, 16), "cancel_after": _integer_rule(0, 8)},
				["cycles", "objects_per_cycle"], true),
			_descriptor("memory.inspect", {"scope": _enum_rule(["scene", "resources"])}, ["scope"], false),
			_descriptor("memory.inject_leak", {}, [], true),
			_descriptor("memory.release", {}, [], true)]
	return []


func apply_operation(name: String, arguments: Dictionary) -> Dictionary:
	if not bool(_state.get("ready", false)):
		return _failure("NOT_READY")
	var result: Dictionary = {}
	match lab_id:
		"LAB-025": result = _apply_replay(name, arguments)
		"LAB-028": result = _apply_threadmill(name, arguments)
		"LAB-036": result = _apply_profiling(name, arguments)
		"LAB-089": result = _apply_sweeps(name, arguments)
		"LAB-091": result = _apply_goldens(name, arguments)
		"LAB-092": result = _apply_memory(name, arguments)
		_: return _failure("UNKNOWN_LAB")
	if result.get("ok", false):
		module_revision += 1
		_state["revision"] = module_revision
	_state["last_code"] = str(result.get("code", "UNKNOWN"))
	_sync_visuals()
	return result


func primary_operation() -> Dictionary:
	match lab_id:
		"LAB-025": return _action("replay.record", {"duration_ticks": 4})
		"LAB-028": return _action("jobs.start", {"seed": 41, "elements": 1024})
		"LAB-036": return _action("profiling.run", {"workload": "baseline", "sample_count": 5, "warm_up": 2})
		"LAB-089": return _action("sweeps.plan", {"start": 1, "end": 5, "step": 1})
		"LAB-091": return _action("goldens.compare", {"channel": "image", "variant": "baseline", "tolerance": 0.0005, "fingerprint": _fixture_hash})
		"LAB-092": return _action("memory.run_cycles", {"cycles": 3, "objects_per_cycle": 4})
	return {}


func observe() -> Dictionary:
	var result: Dictionary = _state.duplicate(true)
	if lab_id == "LAB-028" and _worker != null:
		var worker_status: Dictionary = _worker.status()
		result["worker_progress"] = float(worker_status.get("progress", 0.0))
		result["worker_active"] = bool(worker_status.get("running", false))
	if lab_id == "LAB-028" and _job_registry != null and not _active_job_id.is_empty():
		var job: Dictionary = _job_registry.observe(_active_job_id)
		if job.get("ok", false):
			result["job_registry_state"] = job["job"]["state"]
	if lab_id == "LAB-089" and _job_registry != null and not _active_job_id.is_empty():
		result["job_registry"] = _job_registry.observe(_active_job_id)
	return result


func reset() -> Dictionary:
	match lab_id:
		"LAB-025":
			if bool(_state.get("recording", false)):
				_state["recording"] = false
				_state["recorded_events"] = []
			_state["record_cancelled"] = true
			_state["fixture_x"] = 0
			_state["fixture_y"] = 0
			_state["replay_x"] = 0
			_state["replay_y"] = 0
		"LAB-028":
			if _worker != null:
				var worker_status: Dictionary = _worker.status()
				if bool(worker_status.get("running", false)) or bool(worker_status.get("done", false)):
					var joined: Dictionary = _worker.cancel_and_discard()
					if not joined.get("ok", false):
						return joined
					if not _active_job_id.is_empty():
						var active_job: Dictionary = _job_registry.observe(_active_job_id)
						if active_job.get("ok", false) and active_job["job"].get("state", "") in ["queued", "running"]:
							_job_registry.cancel(_active_job_id)
			_state["job_state"] = "cancelled" if not _active_job_id.is_empty() else "idle"
			_active_job_id = ""
		"LAB-036": _profile_reports.clear()
		"LAB-089":
			if not _active_job_id.is_empty():
				var active: Dictionary = _job_registry.observe(_active_job_id)
				if active.get("ok", false) and active["job"]["state"] in ["queued", "running"]:
					_job_registry.cancel(_active_job_id)
			_active_job_id = ""
			_state["rows"] = []
			_state["sweep_status"] = "idle"
		"LAB-091":
			_goldens.configure()
			_golden_available = true
			_last_golden_candidate.clear()
			_state["last_comparison"] = {}
			_state["proposal"] = {}
		"LAB-092":
			_release_memory_nodes()
			_memory_cache.clear()
			_state["leak_detected"] = false
			_state["cancel_cleanup"] = true
	_state["last_code"] = "RESET"
	_state["revision"] = 0
	module_revision = 0
	_sync_visuals()
	return {"ok": true, "code": "RESET", "namespace": str(lab_context.get("namespace", "player"))}


func teardown() -> void:
	if lab_id == "LAB-028" and _worker != null:
		var worker_status: Dictionary = _worker.status()
		if bool(worker_status.get("running", false)) or bool(worker_status.get("done", false)):
			var joined: Dictionary = _worker.cancel_and_discard()
			if not joined.get("ok", false):
				push_error("Thread Mill worker did not join: " + str(joined.get("code", "UNKNOWN")))
			if not _active_job_id.is_empty() and _job_registry != null:
				var job: Dictionary = _job_registry.observe(_active_job_id)
				if job.get("ok", false) and job["job"].get("state", "") in ["queued", "running"]:
					_job_registry.cancel(_active_job_id)
	if lab_id == "LAB-089" and not _active_job_id.is_empty() and _job_registry != null:
		var active: Dictionary = _job_registry.observe(_active_job_id)
		if active.get("ok", false) and active["job"]["state"] in ["queued", "running"]:
			_job_registry.cancel(_active_job_id)
	if lab_id == "LAB-092":
		_release_memory_nodes()
		_memory_cache.clear()
	super.teardown()


func scenario() -> Array[Dictionary]:
	match lab_id:
		"LAB-025": return [
			_step("replay.record", {"duration_ticks": 4}, {"recording": true, "recording_limit": 4}),
			_step("replay.action", {"direction": "east"}, {"fixture_x": 1}),
			_step("replay.action", {"direction": "north"}, {"fixture_y": 1}),
			_step("replay.action", {"direction": "west"}, {"fixture_x": 0}),
			_step("replay.record", {"duration_ticks": 4}, {"recording": false, "timeline_saved": true, "readback_valid": true}),
			_step("replay.play", {"timeline_id": "observatory-session", "fingerprint": _fixture_hash, "version": 1}, {"semantic_match": true, "replay_y": 1}),
			_step("replay.play", {"timeline_id": "observatory-session", "fingerprint": "0".repeat(64), "version": 1}, {}, false, "FINGERPRINT_MISMATCH"),
			_step("replay.play", {"timeline_id": "observatory-session", "fingerprint": _fixture_hash, "version": 99}, {}, false, "UNSUPPORTED_VERSION"),
			_step("replay.play", {"timeline_id": "observatory-session", "fingerprint": _fixture_hash, "version": 1, "expected_revision": 0}, {}, false, "REVISION_CONFLICT")]
		"LAB-028": return [
			_step("jobs.start", {"seed": 41, "elements": 1024}, {"job_state": "running", "main_thread_commits": 0}, true, "STARTED", 20),
			_step("jobs.poll", {}, {"job_state": "completed", "reference_match": true}, true, "COMPLETED", 0, "", "COMPLETED", 10000),
			_step("jobs.start", {"seed": 9, "elements": 2048}, {"job_state": "running"}, true, "STARTED", 20),
			_step("jobs.cancel", {"job_id": "active"}, {"job_state": "cancelled", "cancelled_no_commit": true,
				"cancel_joined": true, "discarded_pending_result": true}),
			_step("jobs.start", {"seed": 3, "elements": 512}, {"job_state": "running"}, true, "STARTED", 0),
			_step("jobs.start", {"seed": 4, "elements": 512}, {}, false, "DUPLICATE_ACTIVE"),
			_step("jobs.cancel", {"job_id": "active"}, {"cancelled_no_commit": true}),
			_step("jobs.start", {"seed": 4, "elements": 10}, {}, false, "INVALID_BUDGET", 1, "INVALID_ARGUMENT")]
		"LAB-036": return [
			_step("profiling.run", {"workload": "baseline", "sample_count": 5, "warm_up": 2}, {"sample_count": 5, "warm_up_count": 2, "variance_sampled": true}, true, "SAMPLED"),
			_step("profiling.run", {"workload": "optimized", "sample_count": 5, "warm_up": 2}, {"sample_count": 5, "visible_hash": "fixed-specimen"}, true, "SAMPLED"),
			_step("profiling.compare", {"a": "baseline", "b": "optimized"}, {"comparison_available": true, "visible_outcome_equal": true}),
			_step("profiling.run", {"workload": "baseline", "sample_count": 2, "warm_up": 1}, {}, false, "SAMPLE_BUDGET_TOO_SMALL", 1, "INVALID_ARGUMENT"),
			_step("profiling.compare", {"a": "missing", "b": "optimized"}, {}, false, "REPORT_NOT_FOUND")]
		"LAB-089": return [
			_step("sweeps.plan", {"start": 1, "end": 5, "step": 1}, {"proposal_ready": true, "planned_rows": 5}),
			_step("sweeps.run", {"proposal_id": "active", "fingerprint": "active", "cancel_after": 2}, {"sweep_status": "cancelled", "completed_rows": 2, "cancelled_rows": 3}),
			_step("sweeps.run", {"proposal_id": "active", "fingerprint": "active", "cancel_after": 0}, {"sweep_status": "completed", "completed_rows": 5, "resume_skipped": 2}),
			_step("sweeps.run", {"proposal_id": "active", "fingerprint": "0".repeat(64), "cancel_after": 0}, {}, false, "SOURCE_MISMATCH"),
			_step("sweeps.plan", {"start": 7, "end": 2, "step": 1}, {}, false, "INVALID_MATRIX")]
		"LAB-091": return [
			_step("goldens.compare", {"channel": "image", "variant": "baseline", "tolerance": 0.0005, "fingerprint": _fixture_hash}, {"last_comparison": {"passed": true, "metric": "pixels"}}),
			_step("goldens.compare", {"channel": "image", "variant": "mutated", "tolerance": 0.0005, "fingerprint": _fixture_hash}, {"last_comparison": {"passed": false, "metric": "pixels"}}, false, "DIFFERENCE_EXCEEDED"),
			_step("goldens.compare", {"channel": "audio", "variant": "muted", "tolerance": 0.01, "fingerprint": _fixture_hash}, {"last_comparison": {"passed": false, "metric": "audio_bytes", "capture_claim": false}}, false, "DIFFERENCE_EXCEEDED"),
			_step("goldens.propose_update", {"run_id": "gate-run", "channel": "audio", "variant": "muted", "reviewed": false}, {"proposal": {"status": "review_required"}}, false, "REVIEW_REQUIRED"),
			_step("goldens.propose_update", {"run_id": "gate-run", "channel": "audio", "variant": "muted", "reviewed": true}, {"proposal": {"status": "approved"}}),
			_step("goldens.compare", {"channel": "state", "variant": "mutated", "tolerance": 0.01, "fingerprint": "0".repeat(64)}, {}, false, "IDENTITY_MISMATCH"),
			_step("goldens.drop_reference", {}, {"reference_available": false}),
			_step("goldens.compare", {"channel": "state", "variant": "baseline", "tolerance": 0.01, "fingerprint": _fixture_hash}, {}, false, "MISSING_REFERENCE")]
		"LAB-092": return [
			_step("memory.run_cycles", {"cycles": 3, "objects_per_cycle": 4}, {"completed_cycles": 3, "cache_count": 4, "residual_nodes": 0}),
			_step("memory.inspect", {"scope": "resources"}, {"node_counter_status": "available"}),
			_step("memory.run_cycles", {"cycles": 4, "objects_per_cycle": 8, "cancel_after": 2}, {"cancel_cleanup": true, "residual_nodes": 0}, false, "CANCELLED_CLEAN"),
			_step("memory.inject_leak", {}, {"leak_detected": true}),
			_step("memory.inject_leak", {}, {}, false, "LEAK_FIXTURE_ALREADY_ACTIVE"),
			_step("memory.inspect", {"scope": "scene"}, {"leak_detected": true}),
			_step("memory.release", {}, {"leak_detected": false, "residual_nodes": 0})]
	return []


func create_controls(parent: Control) -> void:
	var intro: Label = Label.new()
	intro.text = EXPLANATIONS.get(lab_id, "")
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.custom_minimum_size.x = 320
	parent.add_child(intro)
	var grid: GridContainer = GridContainer.new()
	grid.columns = 2
	parent.add_child(grid)
	match lab_id:
		"LAB-025":
			control_button(grid, "Start / save recording", "replay.record", {"duration_ticks": 4})
			for direction: String in ["east", "north", "west"]:
				control_button(grid, "Fixture step " + direction, "replay.action", {"direction": direction})
			control_button(grid, "Replay saved session", "replay.play", {"timeline_id": "observatory-session", "fingerprint": _fixture_hash, "version": 1})
		"LAB-028":
			control_button(grid, "Start seeded worker", "jobs.start", {"seed": 41, "elements": 1024})
			control_button(grid, "Collect result", "jobs.poll", {})
			control_button(grid, "Cancel and join", "jobs.cancel", {"job_id": "active"})
		"LAB-036":
			control_button(grid, "Sample baseline", "profiling.run", {"workload": "baseline", "sample_count": 5, "warm_up": 2})
			control_button(grid, "Sample optimized", "profiling.run", {"workload": "optimized", "sample_count": 5, "warm_up": 2})
			control_button(grid, "Compare measured runs", "profiling.compare", {"a": "baseline", "b": "optimized"})
		"LAB-089":
			control_button(grid, "Plan five local variants", "sweeps.plan", {"start": 1, "end": 5, "step": 1})
			control_button(grid, "Run / resume local rows", "sweeps.run", {"proposal_id": "active", "fingerprint": "active", "cancel_after": 0})
		"LAB-091":
			control_button(grid, "Compare image specimen", "goldens.compare", {"channel": "image", "variant": "baseline", "tolerance": 0.0005, "fingerprint": _fixture_hash})
			control_button(grid, "Inject one-pixel change", "goldens.compare", {"channel": "image", "variant": "mutated", "tolerance": 0.0005, "fingerprint": _fixture_hash})
			control_button(grid, "Compare PCM silence", "goldens.compare", {"channel": "audio", "variant": "muted", "tolerance": 0.01, "fingerprint": _fixture_hash})
			control_button(grid, "Propose reviewed reference", "goldens.propose_update", {"run_id": "player-review", "channel": "image", "variant": "baseline", "reviewed": true})
		"LAB-092":
			control_button(grid, "Run three allocation cycles", "memory.run_cycles", {"cycles": 3, "objects_per_cycle": 4})
			control_button(grid, "Inspect node counters", "memory.inspect", {"scope": "scene"})
			control_button(grid, "Retain leak fixture", "memory.inject_leak", {})
			control_button(grid, "Release owned resources", "memory.release", {})
	_readout = RichTextLabel.new()
	_readout.custom_minimum_size = Vector2(320, 150)
	_readout.fit_content = true
	parent.add_child(_readout)


func _setup_service() -> void:
	if lab_id == "LAB-025":
		_document_store = DocumentStoreScript.new()
		var owner_namespace: String = str(lab_context.get("namespace", "player"))
		_document_store.configure("data-replay-" + owner_namespace)
		var existing: Dictionary = _document_store.load_document("observatory-session")
		_timeline_revision = int(existing.get("revision", 0)) if existing.get("ok", false) else 0
		_timeline_context = {"seed": 1701, "source": {"commit": "", "tree_hash": _source_fingerprint},
			"fixture": {"id": "replay-observatory-original", "hash": _fixture_hash},
			"tick_rate": 60, "profile": "CoreLocal", "tolerances": {"semantic_exact": 0.0},
			"allowed_operations": ["replay.action"]}
	elif lab_id == "LAB-028":
		_worker = WorkerCoordinatorScript.new()
		_job_registry = JobRegistryScript.new()
		_job_registry.configure("thread-mill")
		_job_registry.interrupt_ownerless()
	elif lab_id == "LAB-036":
		_state["readiness"] = _capability_probe.probe("CoreLocal")
	elif lab_id == "LAB-089":
		_job_registry = JobRegistryScript.new()
		_job_registry.configure("parameter-sweeps")
		_job_registry.interrupt_ownerless()
		_state["cappy_provider"] = "unqualified"
		var requested_providers: Array[String] = ["Cappy"]
		_state["capability"] = _capability_probe.probe("ProductionTools", requested_providers)
	elif lab_id == "LAB-091":
		_goldens = GoldenComparatorScript.new()
		var references: Dictionary = _goldens.configure()
		_state["reference_hashes"] = references
		_state["capture_claim"] = false
	elif lab_id == "LAB-092":
		_state.merge(_read_memory_counters(), true)


func _apply_replay(name: String, args: Dictionary) -> Dictionary:
	match name:
		"replay.record":
			if not bool(_state.get("recording", false)):
				_timeline = SimulationRecordScript.new()
				var setup_result: Dictionary = _timeline.configure(_timeline_context)
				if not setup_result.get("ok", false):
					return _failure("TIMELINE_CONFIG_FAILED", setup_result.get("code", "INVALID_CONTEXT"))
				_state["recording"] = true
				_state["recording_limit"] = int(args["duration_ticks"])
				_state["recorded_events"] = []
				_state["fixture_x"] = 0
				_state["fixture_y"] = 0
				return _success("RECORDING_STARTED")
			var recorded: Array = _state.get("recorded_events", [])
			if recorded.is_empty():
				return _failure("EMPTY_TIMELINE")
			var sequence: int = recorded.size() + 1
			var checkpoint: Dictionary = _timeline.checkpoint(int(recorded[-1]["tick"]), sequence,
				{"fixture_x": int(_state["fixture_x"]), "fixture_y": int(_state["fixture_y"])})
			if not checkpoint.get("ok", false):
				return _failure("TIMELINE_CHECKPOINT_FAILED", checkpoint.get("code", "INVALID_RECORD"))
			var finish_result: Dictionary = _timeline.finish(int(recorded[-1]["tick"]))
			if not finish_result.get("ok", false):
				return _failure("TIMELINE_FINISH_FAILED", finish_result.get("code", "INVALID_ORDER"))
			var record_data: Dictionary = _timeline.export_record()
			var current: Dictionary = _document_store.load_document("observatory-session")
			var expected: int = int(current.get("revision", 0)) if current.get("ok", false) else 0
			var saved: Dictionary = _document_store.save("observatory-session", {"schema_version": 1,
				"timeline": record_data, "fixture_hash": _fixture_hash}, expected,
				"record-%d" % Time.get_ticks_usec())
			if not saved.get("ok", false):
				return _failure("DOCUMENT_SAVE_FAILED", saved.get("code", "WRITE_FAILED"))
			var readback: Dictionary = _document_store.load_document("observatory-session")
			if not readback.get("ok", false) or readback.get("document", {}).get("timeline", {}).get("content_hash", "") != record_data.get("content_hash", ""):
				return _failure("READBACK_MISMATCH")
			_timeline_revision = int(readback["revision"])
			_state["recording"] = false
			_state["timeline_saved"] = true
			_state["readback_valid"] = true
			_state["timeline_id"] = "observatory-session"
			_state["timeline_events"] = recorded.size()
			_state["record_cancelled"] = false
			return _success("TIMELINE_SAVED", {"timeline_id": "observatory-session", "revision": _timeline_revision,
				"events": recorded.size(), "content_hash": record_data["content_hash"]})
		"replay.action":
			var x: int = int(_state.get("fixture_x", 0))
			var y: int = int(_state.get("fixture_y", 0))
			var updated: Vector2i = _move_fixture(x, y, str(args["direction"]))
			if abs(updated.x) > 8 or abs(updated.y) > 8:
				return _failure("FIXTURE_BOUNDS")
			_state["fixture_x"] = updated.x
			_state["fixture_y"] = updated.y
			if bool(_state.get("recording", false)):
				var events: Array = _state["recorded_events"]
				if events.size() >= int(_state["recording_limit"]):
					return _failure("RECORDING_BUDGET_EXCEEDED")
				var tick: int = events.size()
				var operation_result: Dictionary = _timeline.append_operation(tick, tick + 1,
					{"operation": "replay.action", "arguments": {"direction": args["direction"]}})
				if not operation_result.get("ok", false):
					return _failure("TIMELINE_APPEND_FAILED", operation_result.get("code", "INVALID_OPERATION"))
				events.append({"tick": tick, "direction": args["direction"]})
				_state["recorded_events"] = events
			return _success("FIXTURE_ACTION_APPLIED")
		"replay.play":
			if str(args["timeline_id"]) != "observatory-session":
				return _failure("TIMELINE_NOT_FOUND")
			if int(args["version"]) != SimulationRecordScript.VERSION:
				return _failure("UNSUPPORTED_VERSION")
			if str(args["fingerprint"]) != _fixture_hash:
				return _failure("FINGERPRINT_MISMATCH")
			var stored: Dictionary = _document_store.load_document("observatory-session")
			if not stored.get("ok", false):
				return _failure("TIMELINE_UNAVAILABLE", stored.get("code", "NOT_FOUND"))
			if args.has("expected_revision") and int(args["expected_revision"]) != int(stored["revision"]):
				return _failure("REVISION_CONFLICT")
			var document: Dictionary = stored["document"]
			if document.get("schema_version") != 1 or str(document.get("fixture_hash", "")) != _fixture_hash:
				return _failure("FINGERPRINT_MISMATCH")
			var replay_record: RefCounted = SimulationRecordScript.new()
			var loaded: Dictionary = replay_record.load_record(document.get("timeline", {}), _timeline_context)
			if not loaded.get("ok", false):
				return _failure("TIMELINE_REJECTED", loaded.get("code", "INVALID_RECORD"))
			var replay_x: int = 0
			var replay_y: int = 0
			var replayed: int = 0
			for entry: Dictionary in document["timeline"]["operations"]:
				var action_args: Dictionary = entry["arguments"]
				var position: Vector2i = _move_fixture(replay_x, replay_y, str(action_args["direction"]))
				replay_x = position.x
				replay_y = position.y
				replayed += 1
			var checkpoints: Array = document["timeline"]["checkpoints"]
			if checkpoints.is_empty():
				return _failure("TIMELINE_TRUNCATED")
			var final_state: Dictionary = checkpoints[-1]["data"]
			var matches: bool = replay_x == int(final_state.get("fixture_x", -999)) and replay_y == int(final_state.get("fixture_y", -999))
			_state["replay_x"] = replay_x
			_state["replay_y"] = replay_y
			_state["semantic_match"] = matches
			_state["replayed_events"] = replayed
			return {"ok": matches, "code": "REPLAY_MATCH" if matches else "SEMANTIC_MISMATCH",
				"result": {"events": replayed, "final": {"x": replay_x, "y": replay_y}, "match": matches}}
	return _failure("UNKNOWN_OPERATION")


func _apply_threadmill(name: String, args: Dictionary) -> Dictionary:
	match name:
		"jobs.start":
			if not _active_job_id.is_empty():
				var prior_job: Dictionary = _job_registry.observe(_active_job_id)
				if prior_job.get("ok", false) and prior_job["job"].get("state", "") in ["queued", "running"]:
					return _failure("DUPLICATE_ACTIVE")
			var seed_value: int = int(args["seed"])
			var elements: int = int(args["elements"])
			if elements < 64 or elements > WorkerCoordinatorScript.MAX_ELEMENTS:
				return _failure("INVALID_BUDGET")
			var job: Dictionary = _job_registry.create("threadmill", _source_fingerprint,
				{"seed": seed_value, "elements": elements}, {"max_runtime_seconds": 10.0, "max_updates": 4})
			if not job.get("ok", false):
				return _failure("JOB_ADMISSION_FAILED", job.get("code", "INVALID_BUDGET"))
			_active_job_id = str(job["job"]["id"])
			var worker_start: Dictionary = _worker.start(seed_value, elements)
			if not worker_start.get("ok", false):
				_job_registry.cancel(_active_job_id)
				_active_job_id = ""
				return _failure("WORKER_START_FAILED", worker_start.get("code", "WORKER_UNAVAILABLE"))
			var started: Dictionary = _job_registry.advance(_active_job_id, int(job["job"]["revision"]), 0.01)
			if not started.get("ok", false):
				_worker.cancel_and_discard()
				_job_registry.cancel(_active_job_id)
				return _failure("JOB_START_FAILED", started.get("code", "INVALID_JOB"))
			_state["job_state"] = "running"
			_state["job_id"] = _active_job_id
			_state["worker_progress"] = 0.0
			_state["cancelled_no_commit"] = false
			_state["discarded_pending_result"] = false
			_state["main_thread_commits"] = int(_state.get("main_thread_commits", 0))
			return _success("STARTED", {"job_id": _active_job_id, "worker_task": worker_start["task_id"], "local_only": true})
		"jobs.poll":
			if _active_job_id.is_empty():
				return _failure("NO_ACTIVE_JOB")
			var status: Dictionary = _worker.status()
			_state["worker_progress"] = float(status.get("progress", 0.0))
			if not bool(status.get("done", false)):
				return _success("RUNNING", {"progress": _state["worker_progress"]})
			var result: Dictionary = status.get("result", {})
			if result.is_empty():
				return _failure("WORKER_RESULT_MISSING")
			var reference: int = _worker.reference_checksum(int(result["seed"]), int(result["elements"]))
			_state["checksum"] = int(result["checksum"])
			_state["reference_checksum"] = reference
			_state["reference_match"] = reference == int(result["checksum"])
			_state["completed_elements"] = int(result["elements"])
			_state["job_state"] = "completed"
			_state["worker_progress"] = 1.0
			var prior: Dictionary = _job_registry.observe(_active_job_id)
			var advance_result: Dictionary = _job_registry.advance(_active_job_id, int(prior["job"]["revision"]), 0.95)
			if not advance_result.get("ok", false):
				return _failure("JOB_PROGRESS_FAILED", advance_result.get("code", "REVISION_CONFLICT"))
			var finish_result: Dictionary = _job_registry.finish(_active_job_id,
				{"checksum": int(result["checksum"]), "elements": int(result["elements"]), "source_fingerprint": _source_fingerprint})
			if not finish_result.get("ok", false):
				return _failure("JOB_FINISH_FAILED", finish_result.get("code", "INVALID_OUTPUT"))
			_state["main_thread_commits"] = int(_state["main_thread_commits"]) + 1
			_state["cancelled_no_commit"] = false
			return _success("COMPLETED", {"checksum": int(result["checksum"]), "reference_match": _state["reference_match"], "committed_on_main_thread": true})
		"jobs.cancel":
			if _active_job_id.is_empty() or (str(args["job_id"]) != "active" and str(args["job_id"]) != _active_job_id):
				return _failure("JOB_NOT_FOUND")
			var joined: Dictionary = _worker.cancel_and_discard()
			if not joined.get("ok", false):
				return _failure("WORKER_CANCEL_FAILED", joined.get("code", "JOIN_FAILED"))
			var cancelled: Dictionary = _job_registry.cancel(_active_job_id)
			if not cancelled.get("ok", false):
				return _failure("JOB_CANCEL_FAILED", cancelled.get("code", "TERMINAL_JOB"))
			_state["job_state"] = "cancelled"
			_state["cancelled_no_commit"] = true
			_state["cancel_joined"] = bool(joined.get("joined", false))
			_state["discarded_pending_result"] = bool(joined.get("discarded_result", false))
			return _success("CANCELLED", {"joined": _state["cancel_joined"],
				"discarded_result": _state["discarded_pending_result"], "output_committed": false})
	return _failure("UNKNOWN_OPERATION")


func _apply_profiling(name: String, args: Dictionary) -> Dictionary:
	match name:
		"profiling.run":
			var sample_count: int = int(args["sample_count"])
			var warm_up: int = int(args["warm_up"])
			if sample_count < 3:
				return _failure("SAMPLE_BUDGET_TOO_SMALL")
			var workload: String = str(args["workload"])
			var iterations: int = 1600 if workload == "baseline" else 600
			for warm_index: int in range(warm_up):
				_run_profile_work(iterations, warm_index)
			var samples: Array[float] = []
			for sample_index: int in range(sample_count):
				var started_usec: int = Time.get_ticks_usec()
				_run_profile_work(iterations, sample_index + warm_up)
				samples.append(float(Time.get_ticks_usec() - started_usec))
			var total: float = 0.0
			for sample: float in samples:
				total += sample
			var mean: float = total / float(samples.size())
			var variance: float = 0.0
			for sample: float in samples:
				variance += pow(sample - mean, 2.0)
			variance /= float(samples.size())
			var report: Dictionary = {"id": workload, "workload": workload, "warm_up_count": warm_up,
				"sample_count": samples.size(), "sample_window_usec": int(total), "mean_usec": mean,
				"variance_usec": variance, "samples_usec": samples, "visible_hash": "fixed-specimen",
				"engine_process_monitor": _performance_monitor("TIME_PROCESS")}
			_profile_reports[workload] = report
			_state["last_profile"] = report.duplicate(true)
			_state["sample_count"] = sample_count
			_state["warm_up_count"] = warm_up
			_state["sample_window_usec"] = int(total)
			_state["variance_usec"] = variance
			_state["variance_sampled"] = variance >= 0.0
			_state["visible_hash"] = "fixed-specimen"
			return _success("SAMPLED", report)
		"profiling.compare":
			if not _profile_reports.has(args["a"]) or not _profile_reports.has(args["b"]):
				return _failure("REPORT_NOT_FOUND")
			var report_a: Dictionary = _profile_reports[args["a"]]
			var report_b: Dictionary = _profile_reports[args["b"]]
			var comparison: Dictionary = {"comparison_available": true,
				"mean_a_usec": report_a["mean_usec"], "mean_b_usec": report_b["mean_usec"],
				"variance_a_usec": report_a["variance_usec"], "variance_b_usec": report_b["variance_usec"],
				"visible_outcome_equal": report_a["visible_hash"] == report_b["visible_hash"],
				"sample_windows_usec": [report_a["sample_window_usec"], report_b["sample_window_usec"]],
				"fps_claim": false}
			_state.merge(comparison, true)
			return _success("COMPARED", comparison)
	return _failure("UNKNOWN_OPERATION")


func _apply_sweeps(name: String, args: Dictionary) -> Dictionary:
	match name:
		"sweeps.plan":
			var start_value: int = int(args["start"])
			var end_value: int = int(args["end"])
			var step_value: int = int(args["step"])
			if start_value > end_value or step_value < 1:
				return _failure("INVALID_MATRIX")
			var values: Array[int] = []
			for value: int in range(start_value, end_value + 1, step_value):
				values.append(value)
				if values.size() > 8:
					return _failure("SWEEP_BUDGET_EXCEEDED")
			var fingerprint: String = _hash_text("%s|%s|%s|%s" % [_source_fingerprint, _fixture_hash, values, "sweep-v1"])
			_sweep_proposal = {"id": "sweep-" + fingerprint.substr(0, 12), "fingerprint": fingerprint,
				"source_fingerprint": _source_fingerprint, "fixture_hash": _fixture_hash,
				"values": values, "rows": []}
			_state["proposal_ready"] = true
			_state["proposal_id"] = _sweep_proposal["id"]
			_state["proposal_fingerprint"] = fingerprint
			_state["planned_rows"] = values.size()
			_state["estimated_work_units"] = values.size() * 512
			_state["sweep_status"] = "planned"
			_state["rows"] = []
			return _success("PLANNED", {"proposal_id": _sweep_proposal["id"], "fingerprint": fingerprint,
				"rows": values.size(), "cappy": "unqualified", "execution": "local_computation"})
		"sweeps.run":
			var requested_id: String = str(args["proposal_id"])
			if requested_id == "active":
				requested_id = str(_sweep_proposal.get("id", ""))
			if _sweep_proposal.is_empty() or requested_id != str(_sweep_proposal["id"]):
				return _failure("PROPOSAL_NOT_FOUND")
			var requested_fingerprint: String = str(args["fingerprint"])
			if requested_fingerprint == "active":
				requested_fingerprint = str(_sweep_proposal["fingerprint"])
			if requested_fingerprint != str(_sweep_proposal["fingerprint"]) or _source_fingerprint != str(_sweep_proposal["source_fingerprint"]):
				return _failure("SOURCE_MISMATCH")
			var values: Array = _sweep_proposal["values"]
			var rows: Array = _sweep_proposal["rows"]
			var total_rows: int = values.size()
			while rows.size() < total_rows:
				var new_index: int = rows.size()
				rows.append({"index": new_index, "parameter": int(values[new_index]), "status": "pending"})
			var job_result: Dictionary = _job_registry.create("parameter-sweep", _source_fingerprint,
				{"proposal": _sweep_proposal["id"], "remaining": total_rows - _passed_rows(rows)},
				{"max_runtime_seconds": 10.0, "max_updates": 16})
			if not job_result.get("ok", false):
				return _failure("JOB_ADMISSION_FAILED", job_result.get("code", "CAPACITY_EXCEEDED"))
			_active_job_id = str(job_result["job"]["id"])
			var progressed: int = 0
			var cancel_after: int = int(args.get("cancel_after", 0))
			_state["resume_skipped"] = _passed_rows(rows)
			for row_index: int in range(total_rows):
				if rows[row_index].get("status", "") == "passed":
					continue
				if cancel_after > 0 and progressed >= cancel_after:
					rows[row_index]["status"] = "cancelled"
					continue
				var parameter: int = int(values[row_index])
				var measurement: float = _sweep_measure(parameter, 512)
				var row: Dictionary = {"index": row_index, "parameter": parameter, "measurement": measurement,
					"status": "passed", "result_hash": _hash_text("%s:%s:%s" % [_fixture_hash, parameter, measurement])}
				if row_index < rows.size():
					rows[row_index] = row
				else:
					rows.append(row)
				progressed += 1
				var registry_job: Dictionary = _job_registry.observe(_active_job_id)["job"]
				var fraction: float = float(_passed_rows(rows)) / float(total_rows)
				var advance: Dictionary = _job_registry.advance(_active_job_id, int(registry_job["revision"]), minf(0.99, fraction))
				if not advance.get("ok", false):
					_job_registry.cancel(_active_job_id)
					return _failure("JOB_PROGRESS_FAILED", advance.get("code", "REVISION_CONFLICT"))
			_sweep_proposal["rows"] = rows
			_state["rows"] = rows.duplicate(true)
			_state["completed_rows"] = _passed_rows(rows)
			_state["cancelled_rows"] = _count_status(rows, "cancelled")
			_state["sweep_status"] = "cancelled" if _state["cancelled_rows"] > 0 else "completed"
			if _state["sweep_status"] == "cancelled":
				_job_registry.cancel(_active_job_id)
				return _success("CANCELLED", {"completed_rows": _state["completed_rows"],
					"cancelled_rows": _state["cancelled_rows"], "resumable": true})
			var final_job: Dictionary = _job_registry.observe(_active_job_id)["job"]
			_job_registry.advance(_active_job_id, int(final_job["revision"]), 1.0)
			var output: Dictionary = _job_registry.finish(_active_job_id, {"proposal": _sweep_proposal["id"],
				"rows": rows, "source_fingerprint": _source_fingerprint})
			if not output.get("ok", false):
				return _failure("JOB_FINISH_FAILED", output.get("code", "INVALID_OUTPUT"))
			return _success("SWEEP_COMPLETED", {"completed_rows": _state["completed_rows"],
				"resume_skipped": _state["resume_skipped"], "rows": rows})
		"sweeps.observe": return _success("OBSERVED", {"rows": _sweep_proposal.get("rows", []).duplicate(true), "status": _state.get("sweep_status", "idle")})
	return _failure("UNKNOWN_OPERATION")


func _apply_goldens(name: String, args: Dictionary) -> Dictionary:
	match name:
		"goldens.compare":
			if not _golden_available:
				return _failure("MISSING_REFERENCE")
			if str(args["fingerprint"]) != _fixture_hash:
				return _failure("IDENTITY_MISMATCH")
			var comparison: Dictionary = _goldens.compare(str(args["channel"]), str(args["variant"]), float(args["tolerance"]))
			if comparison.get("code", "") in ["UNKNOWN_CHANNEL", "INVALID_VARIANT"]:
				return _failure(str(comparison["code"]))
			_last_golden_candidate = {"channel": args["channel"], "variant": args["variant"],
				"candidate_sha256": comparison.get("candidate_sha256", ""), "metrics": comparison.duplicate(true)}
			_state["last_comparison"] = {"passed": bool(comparison.get("ok", false)),
				"metric": comparison.get("metric", "unknown"), "difference": comparison.get("difference", 0.0),
				"tolerance": comparison.get("tolerance", args["tolerance"]),
				"reference_sha256": comparison.get("reference_sha256", ""),
				"candidate_sha256": comparison.get("candidate_sha256", ""),
				"capture_claim": false}
			if not comparison.get("ok", false):
				return {"ok": false, "code": comparison.get("code", "DIFFERENCE_EXCEEDED"), "result": _state["last_comparison"]}
			return _success(str(comparison.get("code", "WITHIN_TOLERANCE")), _state["last_comparison"])
		"goldens.drop_reference":
			_golden_available = false
			_state["reference_available"] = false
			return _success("REFERENCE_REMOVED")
		"goldens.propose_update":
			var proposal: Dictionary = {"run_id": args["run_id"], "channel": args["channel"],
				"variant": args["variant"], "candidate_sha256": str(_last_golden_candidate.get("candidate_sha256", "")),
				"status": "review_required"}
			if not bool(args["reviewed"]):
				_state["proposal"] = proposal
				return {"ok": false, "code": "REVIEW_REQUIRED", "result": {"proposal": proposal}}
			var updated: Dictionary = _goldens.update_reference(str(args["channel"]), str(args["variant"]))
			if not updated.get("ok", false):
				return _failure(updated.get("code", "UPDATE_REJECTED"))
			proposal["status"] = "approved"
			proposal["reviewed"] = true
			proposal["reference_update"] = "applied_after_explicit_review"
			_golden_available = true
			_state["reference_available"] = true
			_state["proposal"] = proposal
			return _success("REFERENCE_UPDATED_AFTER_REVIEW", {"proposal": proposal})
	return _failure("UNKNOWN_OPERATION")


func _apply_memory(name: String, args: Dictionary) -> Dictionary:
	match name:
		"memory.run_cycles":
			var cycles: int = int(args["cycles"])
			var objects_per_cycle: int = int(args["objects_per_cycle"])
			if cycles < 1 or cycles > 8 or objects_per_cycle < 1 or objects_per_cycle > 16 or cycles * objects_per_cycle > 64:
				return _failure("RESOURCE_BUDGET_EXCEEDED")
			var baseline: Dictionary = _read_memory_counters()
			var completed: int = 0
			var cancel_after: int = int(args.get("cancel_after", 0))
			for cycle: int in range(cycles):
				var owned_nodes: Array[MeshInstance3D] = []
				for item: int in range(objects_per_cycle):
					var mesh: BoxMesh = BoxMesh.new()
					mesh.size = Vector3(0.2 + float(item) * 0.01, 0.2, 0.2)
					var instance: MeshInstance3D = MeshInstance3D.new()
					instance.mesh = mesh
					instance.position = Vector3(float(item) * 0.25, 0.35, float(cycle) * 0.3)
					add_child(instance)
					owned_nodes.append(instance)
					_memory_cache.append(mesh)
					while _memory_cache.size() > 4:
						_memory_cache.pop_front()
				for owned: MeshInstance3D in owned_nodes:
					remove_child(owned)
					owned.free()
				completed += 1
				if cancel_after > 0 and completed >= cancel_after:
					_state["completed_cycles"] = completed
					_state["cache_count"] = _memory_cache.size()
					_state["cancel_cleanup"] = _read_memory_counters().get("node_count", {}).get("value", -1) == baseline.get("node_count", {}).get("value", -2)
					_state["residual_nodes"] = 0 if _state["cancel_cleanup"] else 1
					return {"ok": false, "code": "CANCELLED_CLEAN" if _state["cancel_cleanup"] else "CANCELLED_LEAKED"}
			var after: Dictionary = _read_memory_counters()
			var before_nodes: Variant = baseline.get("node_count", {}).get("value", null)
			var after_nodes: Variant = after.get("node_count", {}).get("value", null)
			var residual: int = int(after_nodes) - int(before_nodes) if before_nodes is int or before_nodes is float else -1
			_state["completed_cycles"] = cycles
			_state["cache_count"] = _memory_cache.size()
			_state["baseline_node_count"] = before_nodes
			_state["node_count_after"] = after_nodes
			_state["residual_nodes"] = residual
			_state["bounded_trend"] = residual <= 0 and _memory_cache.size() <= 4
			_state["cancel_cleanup"] = true
			return _success("CYCLES_COMPLETE", {"completed_cycles": cycles, "objects_per_cycle": objects_per_cycle,
				"cache_count": _memory_cache.size(), "residual_nodes": residual,
				"bounded_trend": _state["bounded_trend"], "counters": after})
		"memory.inspect":
			var counters: Dictionary = _read_memory_counters()
			_state["counters"] = counters
			var node_value: Variant = counters.get("node_count", {}).get("value", null)
			_state["node_counter_status"] = str(counters.get("node_count", {}).get("status", "unavailable"))
			var baseline_value: Variant = _state.get("baseline_node_count", node_value)
			_state["leak_detected"] = _intentional_leak != null or (node_value is int or node_value is float) and (baseline_value is int or baseline_value is float) and float(node_value) > float(baseline_value)
			_state["missing_counters"] = _missing_counters(counters)
			return _success("INSPECTED", {"counters": counters, "leak_detected": _state["leak_detected"],
				"missing_counters": _state["missing_counters"]})
		"memory.inject_leak":
			if _intentional_leak != null and is_instance_valid(_intentional_leak):
				return _failure("LEAK_FIXTURE_ALREADY_ACTIVE")
			_intentional_leak = MeshInstance3D.new()
			_intentional_leak.mesh = BoxMesh.new()
			_intentional_leak.name = "IntentionalLeakFixture"
			add_child(_intentional_leak)
			_state["leak_detected"] = true
			_state["leak_node_count"] = int(_read_memory_counters().get("node_count", {}).get("value", 0))
			return _success("LEAK_FIXTURE_CREATED")
		"memory.release":
			_release_memory_nodes()
			_memory_cache.clear()
			var after_release: Dictionary = _read_memory_counters()
			_state["cache_count"] = 0
			_state["leak_detected"] = false
			_state["node_count_after"] = after_release.get("node_count", {}).get("value", null)
			_state["residual_nodes"] = 0
			_state["bounded_trend"] = true
			return _success("OWNED_RESOURCES_RELEASED", {"counters": after_release})
	return _failure("UNKNOWN_OPERATION")


func _build_exhibit() -> void:
	var accent: Color = Color("4ca9a4")
	match lab_id:
		"LAB-025": accent = Color("5bd4be")
		"LAB-028": accent = Color("e6b35b")
		"LAB-036": accent = Color("ee8064")
		"LAB-089": accent = Color("92c76e")
		"LAB-091": accent = Color("83a9df")
		"LAB-092": accent = Color("d387bd")
	_create_label(String(TITLES.get(lab_id, lab_id)), Vector3(0, 4.3, -3.5), accent, 38)
	for index: int in range(5):
		var block: MeshInstance3D = box(Vector3(-5.0 + float(index) * 2.5, 0.8, -1.8),
			Vector3(1.2, 1.3 + float(index % 2) * 0.35, 1.0), accent.darkened(float(index) * 0.08))
		_display_blocks.append(block)
	box(Vector3(0, 0.05, 1.6), Vector3(11.0, 0.2, 3.0), Color("17384a"))
	_create_label(_exhibit_hint(), Vector3(0, 2.4, 3.6), Color("e9b75b"), 17)
	_state["fixture_visible"] = true


func _exhibit_hint() -> String:
	match lab_id:
		"LAB-025": return "ORDERED EVENT / RESET / SEMANTIC REPLAY"
		"LAB-028": return "WORKER DATA -> MAIN THREAD COMMIT"
		"LAB-036": return "WARM-UP / SAMPLES / VARIANCE"
		"LAB-089": return "LOCAL SWEEP / BOUNDED ROWS / RESUME"
		"LAB-091": return "PIXELS / PCM / SEMANTIC ASSERTIONS"
		"LAB-092": return "ALLOCATE / RELEASE / INSPECT RESIDUALS"
	return "BOUNDED DATA LAB"


func _create_label(text_value: String, at: Vector3, color: Color, font_size: int) -> Label3D:
	var label: Label3D = Label3D.new()
	label.text = text_value
	label.position = at
	label.font_size = font_size
	label.pixel_size = 0.008
	label.modulate = color
	label.outline_size = 4
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)
	return label


func _read_memory_counters() -> Dictionary:
	var counters: Dictionary = {}
	if ClassDB.class_has_method("Performance", "get_monitor"):
		counters["object_count"] = {"status": "available", "value": int(Performance.get_monitor(Performance.OBJECT_COUNT))}
		counters["node_count"] = {"status": "available", "value": int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))}
		counters["resource_count"] = {"status": "available", "value": int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))}
	else:
		counters["object_count"] = {"status": "unavailable", "value": null}
		counters["node_count"] = {"status": "unavailable", "value": null}
		counters["resource_count"] = {"status": "unavailable", "value": null}
	if ClassDB.class_has_method("Performance", "get_monitor"):
		var memory_value: float = Performance.get_monitor(Performance.MEMORY_STATIC)
		counters["static_memory_bytes"] = {"status": "available", "value": int(memory_value)}
	else:
		counters["static_memory_bytes"] = {"status": "unavailable", "value": null}
	return counters


func _performance_monitor(name: String) -> Dictionary:
	if not ClassDB.class_has_method("Performance", "get_monitor"):
		return {"status": "unavailable", "value": null}
	if name == "TIME_PROCESS":
		return {"status": "available", "value": Performance.get_monitor(Performance.TIME_PROCESS)}
	return {"status": "unavailable", "value": null}


func _missing_counters(counters: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for key: String in counters:
		if counters[key].get("status", "unavailable") != "available":
			missing.append(key)
	return missing


func _release_memory_nodes() -> void:
	if is_instance_valid(_intentional_leak):
		if _intentional_leak.get_parent() == self:
			remove_child(_intentional_leak)
		_intentional_leak.free()
	_intentional_leak = null
	for child: Node in get_children():
		if child.name == "MemoryCycleFixture":
			remove_child(child)
			child.free()


func _run_profile_work(iterations: int, salt: int) -> float:
	var accumulator: float = float(salt + 1)
	for index: int in range(iterations):
		accumulator = fposmod(accumulator * 1.61803398875 + float(index % 31) * 0.013, 997.0)
	return accumulator


func _sweep_measure(parameter: int, count: int) -> float:
	var accumulator: float = float(parameter)
	for index: int in range(count):
		accumulator = fposmod(accumulator * 1.001 + float((index * parameter) % 17) * 0.07, 10000.0)
	return accumulator


func _passed_rows(rows: Array) -> int:
	return _count_status(rows, "passed")


func _count_status(rows: Array, status: String) -> int:
	var count: int = 0
	for row: Variant in rows:
		if row is Dictionary and row.get("status", "") == status:
			count += 1
	return count


func _move_fixture(x: int, y: int, direction: String) -> Vector2i:
	match direction:
		"east": x += 1
		"west": x -= 1
		"north": y += 1
		"south": y -= 1
	return Vector2i(x, y)


func _load_source_fingerprint() -> Dictionary:
	var file: FileAccess = FileAccess.open(FINGERPRINT_MANIFEST, FileAccess.READ)
	if file == null:
		return {"fingerprint": "", "verified": false, "status": "manifest_unavailable"}
	var parser: JSON = JSON.new()
	var parse_result: Error = parser.parse(file.get_as_text())
	file.close()
	if parse_result != OK or not parser.data is Dictionary:
		return {"fingerprint": "", "verified": false, "status": "manifest_invalid"}
	var manifest: Dictionary = parser.data
	var files: Dictionary = manifest.get("files", {})
	if files.is_empty() or not manifest.get("algorithm", "") == "sha256-source-set-v1":
		return {"fingerprint": "", "verified": false, "status": "manifest_invalid"}
	var paths: Array[String] = []
	for path_value: Variant in files.keys():
		paths.append(str(path_value))
	paths.sort()
	var canonical: String = ""
	var available_sources: int = 0
	for path: String in paths:
		var expected_hash: String = str(files[path])
		if expected_hash.length() != 64:
			return {"fingerprint": "", "verified": false, "status": "manifest_invalid"}
		canonical += path + ":" + expected_hash + "\n"
		if FileAccess.file_exists(path):
			var source_bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
			if source_bytes.is_empty() or _sha256_bytes(source_bytes) != expected_hash:
				return {"fingerprint": "", "verified": false, "status": "source_mismatch"}
			available_sources += 1
	var calculated: String = canonical.sha256_text()
	if calculated != str(manifest.get("fingerprint", "")):
		return {"fingerprint": "", "verified": false, "status": "manifest_fingerprint_mismatch"}
	if available_sources > 0 and available_sources != paths.size():
		return {"fingerprint": "", "verified": false, "status": "partial_source_set"}
	return {"fingerprint": calculated, "verified": available_sources == paths.size(),
		"status": "source_files_verified" if available_sources == paths.size() else "bundled_manifest_unverified"}


func _hash_text(text: String) -> String:
	return text.sha256_text()


func _sha256_bytes(bytes: PackedByteArray) -> String:
	var hashing: HashingContext = HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(bytes)
	return hashing.finish().hex_encode()


func _descriptor(name: String, rules: Dictionary, required: Array, mutates: bool) -> Dictionary:
	return {"name": name, "scope": "active-module", "arguments": rules,
		"required": required, "mutates": mutates}


func _integer_rule(minimum: int, maximum: int) -> Dictionary:
	return {"type": "integer", "min": minimum, "max": maximum}


func _string_rule(maximum: int) -> Dictionary:
	return {"type": "string", "max_length": maximum}


func _enum_rule(values: Array) -> Dictionary:
	return {"type": "enum", "values": values}


func _action(operation: String, arguments: Dictionary) -> Dictionary:
	return {"operation": operation, "arguments": arguments}


func _step(operation: String, arguments: Dictionary, assertions: Dictionary = {}, expected_ok: bool = true,
		expected_code: String = "", wait_ticks: int = 1, expected_bus_code: String = "",
		poll_until_code: String = "", timeout_msec: int = 0) -> Dictionary:
	var step: Dictionary = {"operation": operation, "arguments": arguments,
		"expect_ok": expected_ok, "assert": assertions, "wait_ticks": wait_ticks}
	if not expected_code.is_empty():
		step["expect_code"] = expected_code
	if not expected_bus_code.is_empty():
		step["expect_bus_code"] = expected_bus_code
	if not poll_until_code.is_empty():
		step["poll_until_code"] = poll_until_code
		step["timeout_msec"] = timeout_msec
	return step


func _success(code: String, result: Dictionary = {}) -> Dictionary:
	return {"ok": true, "code": code, "result": result}


func _failure(code: String, message: String = "") -> Dictionary:
	var result: Dictionary = {"ok": false, "code": code}
	if not message.is_empty():
		result["message"] = message
	return result


func _action_label() -> String:
	return String({"LAB-025": "Record / replay", "LAB-028": "Start bounded worker",
		"LAB-036": "Measure workload", "LAB-089": "Plan local sweep",
		"LAB-091": "Compare specimen", "LAB-092": "Run lifecycle cycles"}.get(lab_id, "Operate"))


func _readiness() -> String:
	if lab_id == "LAB-089":
		return "local_computation_ready; Cappy capture unqualified"
	if lab_id == "LAB-036":
		return "runtime counters probed; no FPS or hardware claim"
	if lab_id == "LAB-092":
		return "engine counters reported per-monitor; unavailable values remain explicit"
	return "original local fixture; provider and device acceptance unqualified"


func _limits() -> String:
	match lab_id:
		"LAB-025": return "At most 60 operation ticks and 64 recorded actions. Replay compares semantic fixture state; physics and pixel identity are not promised."
		"LAB-028": return "One WorkerThreadPool task, at most 4096 integers, 10-second job budget. Worker creates no scene objects; cancellation joins before release."
		"LAB-036": return "3-32 measured samples and 1-16 warm-up runs. Durations are this host's script-work measurements, not FPS claims."
		"LAB-089": return "At most eight local rows and 4096 work units per row. Cappy provider execution/capture is unqualified. Checkpoints bind module, fixture and recipe hashes."
		"LAB-091": return "16x16 image region and 256 mono PCM samples. Bytes are in-memory fixtures; comparison is not recording or playback evidence."
		"LAB-092": return "At most eight cycles, sixteen MeshInstances per cycle and four retained Mesh resources. OS memory noise is reported separately from owned nodes."
	return "Bounded local fixture."


func _sync_visuals() -> void:
	var value: float = 0.0
	match lab_id:
		"LAB-025": value = float(_state.get("timeline_events", _state.get("fixture_x", 0))) / 8.0
		"LAB-028": value = float(_state.get("worker_progress", 0.0))
		"LAB-036": value = minf(float(_state.get("sample_count", 0)) / 32.0, 1.0)
		"LAB-089": value = float(_state.get("completed_rows", 0)) / maxf(float(_state.get("planned_rows", 1)), 1.0)
		"LAB-091": value = 1.0 if bool(_state.get("last_comparison", {}).get("passed", false)) else 0.25
		"LAB-092": value = 1.0 if bool(_state.get("leak_detected", false)) else minf(float(_state.get("completed_cycles", 0)) / 8.0, 1.0)
	for index: int in range(_display_blocks.size()):
		var block: MeshInstance3D = _display_blocks[index]
		var fill: float = clampf(value * 4.0 - float(index), 0.0, 1.0)
		block.scale.y = 0.45 + fill * 0.9
		block.position.y = 0.5 + block.scale.y * 0.5
		block.material_override = material(Color("ed8064") if index == 0 and not bool(_state.get("last_comparison", {}).get("passed", true)) else Color("75dfb8").lerp(Color("e9b75b"), float(index) / 5.0), true)
	if is_instance_valid(_readout):
		_readout.text = JSON.stringify(observe(), "  ")
