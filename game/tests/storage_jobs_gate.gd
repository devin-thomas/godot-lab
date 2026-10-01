extends SceneTree

const DocumentStoreScript: GDScript = preload("res://domain/document_store.gd")
const FixtureRegistryScript: GDScript = preload("res://domain/fixture_registry.gd")
const JobRegistryScript: GDScript = preload("res://domain/job_registry.gd")
const CapabilityProbeScript: GDScript = preload("res://domain/capability_probe.gd")

var _check_count: int = 0


func _initialize() -> void:
	var failures: Array[String] = []
	_check(DocumentStoreScript.can_instantiate(), "document store script loads", failures)
	_check(FixtureRegistryScript.can_instantiate(), "fixture registry script loads", failures)
	_check(JobRegistryScript.can_instantiate(), "job registry script loads", failures)
	_check(CapabilityProbeScript.can_instantiate(), "capability probe script loads", failures)
	if failures.is_empty():
		_check_services(DocumentStoreScript, FixtureRegistryScript, JobRegistryScript, CapabilityProbeScript, failures)
	for failure: String in failures:
		push_error("STORAGE_JOBS_GATE " + failure)
	print("STORAGE_JOBS_GATE %s (%d checks, %d failures)" % ["PASS" if failures.is_empty() else "FAIL", _check_count, failures.size()])
	quit(0 if failures.is_empty() else 1)


func _check_services(document_script: GDScript, fixture_script: GDScript,
		job_script: GDScript, probe_script: GDScript, failures: Array[String]) -> void:
	var documents: Variant = document_script.new()
	documents.directory = "user://godot-lab-storage-jobs-gate"
	_check(documents.configure("demo").get("ok", false), "document namespace configures", failures)
	_check(documents.save("../escape", {"x": 1}).get("code", "") == "invalid_id", "document traversal ID rejects", failures)
	var saved: Dictionary = documents.save("roundtrip", {"title": "fixture", "future_metadata": {"keep": true}}, 0, "request-one")
	_check(saved.get("ok", false) and saved.get("revision", 0) == 1, "schema-1 document saves", failures)
	var loaded: Dictionary = documents.load_document("roundtrip")
	_check(loaded.get("ok", false) and loaded.get("document", {}).get("future_metadata", {}).get("keep", false), "unknown document metadata round-trips", failures)
	_check(documents.save("roundtrip", {"title": "fixture", "future_metadata": {"keep": true}}, 0, "request-one").get("replayed", false), "same request retries without duplicate commit", failures)
	var updated: Dictionary = documents.save("roundtrip", {"title": "updated", "future_metadata": {"keep": true}}, 1, "request-two")
	_check(updated.get("ok", false) and updated.get("revision", 0) == 2, "atomic write replaces an existing document", failures)
	var replay_after_update: Dictionary = documents.save("roundtrip", {"title": "fixture", "future_metadata": {"keep": true}}, 0, "request-one")
	_check(replay_after_update.get("replayed", false) and documents.load_document("roundtrip").get("revision", 0) == 2, "older retry does not roll back later revision", failures)
	_check(documents.save("roundtrip", {"title": "changed"}, 0, "request-one").get("code", "") == "request_conflict", "conflicting request reuse rejects", failures)
	_check(documents.save("roundtrip", {"title": "changed"}, 0).get("code", "") == "revision_conflict", "stale document revision rejects", failures)
	_check(documents.save("roundtrip", {"huge": "x".repeat(262145)}).get("code", "") == "document_too_large", "oversized document rejects", failures)
	var path: String = "user://godot-lab-storage-jobs-gate/demo/roundtrip.json"
	var before_corruption: PackedByteArray = FileAccess.get_file_as_bytes(path)
	var corrupt_file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	corrupt_file.store_string("{truncated")
	corrupt_file.close()
	_check(documents.load_document("roundtrip").get("code", "") == "malformed_document", "truncated document reports failure", failures)
	_check(FileAccess.file_exists(path), "invalid document bytes remain for recovery", failures)
	var restore_file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	restore_file.store_buffer(before_corruption)
	restore_file.close()
	_check(documents.configure("another").get("ok", false), "separate document namespace configures", failures)
	_check(documents.reset_demo().get("code", "") == "reset_scope_denied", "demo reset cannot clear another namespace", failures)
	documents.configure("demo")
	_check(documents.reset_demo().get("ok", false), "demo namespace reset succeeds", failures)

	var fixtures: Variant = fixture_script.new()
	fixtures.configure("gate")
	var payload: String = "{\"schema_version\":1,\"metadata\":{\"label\":\"sample\"}}"
	var registered: Dictionary = fixtures.register_fixture("sample", {"payload": payload,
		"source": "original gate fixture", "license": "CC0-1.0", "version": 1})
	_check(registered.get("ok", false) and str(registered.get("manifest", {}).get("sha256", "")).length() == 64, "fixture registration computes hash", failures)
	_check(fixtures.probe_fixture("sample").get("route", "") == "original_local_fixture", "fixture probe reports local route", failures)
	_check(fixtures.load_fixture("sample").get("payload", PackedByteArray()).size() == payload.to_utf8_buffer().size(), "registered fixture bytes remain available", failures)
	_check(fixtures.register_fixture("../escape", {"payload": payload, "source": "test", "license": "CC0"}).get("code", "") == "invalid_id", "fixture traversal ID rejects", failures)
	_check(fixtures.stage_import("traversal", "{\"schema_version\":1,\"asset_path\":\"../../secret\"}".to_utf8_buffer()).get("code", "") == "unsafe_path", "traversing import path rejects", failures)
	_check(fixtures.stage_import("native", PackedByteArray([77, 90, 0, 0])).get("code", "") == "native_payload_rejected", "native executable import rejects", failures)
	_check(fixtures.stage_import("broken", "{\"schema_version\":".to_utf8_buffer()).get("code", "") == "malformed_import", "malformed import rejects", failures)
	_check(fixtures.stage_import("portable", payload.to_utf8_buffer()).get("ok", false), "bounded portable JSON stages", failures)
	_check(fixtures.clear_staging().get("removed", 0) == 1, "staging cleanup is namespace scoped", failures)
	_check(fixtures.list_fixtures().get("fixtures", []).size() == 1, "registered fixtures remain outside staging", failures)

	var jobs: Variant = job_script.new()
	jobs.configure("gate")
	var created: Dictionary = jobs.create("render", "source-a", {"quality": "low"}, {"max_runtime_seconds": 10.0, "max_updates": 3})
	var job: Dictionary = created.get("job", {})
	var job_id: String = str(job.get("id", ""))
	_check(created.get("ok", false) and created.get("local_only", false), "job admission is explicitly local", failures)
	var advanced: Dictionary = jobs.advance(job_id, int(job.get("revision", 0)), 0.5)
	_check(advanced.get("ok", false) and advanced.get("job", {}).get("state", "") == "running", "job progress advances", failures)
	_check(jobs.advance(job_id, int(advanced.get("job", {}).get("revision", 0)), 0.4).get("code", "") == "invalid_progress", "job progress cannot decrease", failures)
	var completed: Dictionary = jobs.finish(job_id, {"artifact_hash": "abc123", "format": "fixture"})
	_check(completed.get("ok", false) and completed.get("job", {}).get("state", "") == "completed", "job output commits on completion", failures)
	_check(jobs.cancel(job_id).get("code", "") == "terminal_job", "terminal job is immutable", failures)
	var next_created: Dictionary = jobs.create("render", "source-b", {"quality": "high"}, {"max_runtime_seconds": 10.0, "max_updates": 3})
	var next_job: Dictionary = next_created.get("job", {})
	var cancelled: Dictionary = jobs.cancel(str(next_job.get("id", "")))
	_check(cancelled.get("ok", false), "active job cancels", failures)
	_check(jobs.observe().get("last_good_outputs", {}).has("render"), "cancellation preserves previous output", failures)
	var limited: Dictionary = jobs.create("analysis", "source-c", {}, {"max_runtime_seconds": 10.0, "max_updates": 1})
	var limited_job: Dictionary = limited.get("job", {})
	var first_update: Dictionary = jobs.advance(str(limited_job.get("id", "")), int(limited_job.get("revision", 0)), 0.1)
	_check(jobs.advance(str(limited_job.get("id", "")), int(first_update.get("job", {}).get("revision", 0)), 0.2).get("code", "") == "budget_exceeded", "job update budget interrupts work", failures)
	_check(jobs.observe(job_id).get("job", {}).get("output_manifest", {}).has("artifact_hash"), "completed output remains observable", failures)
	_check(jobs.reset().get("namespace", "") == "gate", "job reset reports owned namespace", failures)
	_check(jobs.observe().get("jobs", []).is_empty(), "job reset clears owned jobs", failures)

	var probe: Variant = probe_script.new()
	var core: Dictionary = probe.probe("CoreLocal")
	_check(core.get("ok", false) and core.get("readiness", "") == "ready", "CoreLocal reports runtime readiness", failures)
	_check(core.get("facts", {}).get("physical_support", "") == "unverified", "probe leaves physical support unverified", failures)
	var requested_providers: Array[String] = ["StorageJobsGateMissingProvider"]
	var missing: Dictionary = probe.probe("ProductionTools", requested_providers)
	_check(missing.get("readiness", "") == "unavailable" and missing.get("missing_providers", []).has("StorageJobsGateMissingProvider"), "missing provider is distinguished", failures)
	_check(missing.get("fallback", "").contains("Ordinary local play"), "missing provider reports useful fallback", failures)
	_check(probe.probe("unknown").get("code", "") == "unknown_profile", "unknown profile is explicit", failures)


func _check(condition: bool, description: String, failures: Array[String]) -> void:
	_check_count += 1
	if not condition:
		failures.append(description)
