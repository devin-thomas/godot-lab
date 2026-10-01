extends RefCounted

const MAX_JOBS: int = 32
const MAX_RECIPE_BYTES: int = 65536
const MAX_OUTPUT_BYTES: int = 65536
const MAX_RUNTIME_SECONDS: float = 3600.0
const MAX_UPDATES: int = 10000

var job_namespace: String = "demo"
var _jobs: Dictionary = {}
var _last_outputs: Dictionary = {}
var _sequence: int = 0
var _owner_token: int = Time.get_ticks_usec()


func configure(value: String) -> Dictionary:
	if not _is_safe_id(value):
		return _failure("invalid_namespace", "Namespace must be a safe identifier.")
	job_namespace = value
	_jobs.clear()
	_last_outputs.clear()
	return {"ok": true, "code": "configured", "namespace": job_namespace}


func create(kind: String, source_fingerprint: String, recipe: Dictionary,
		budget: Dictionary) -> Dictionary:
	if not _is_safe_id(kind):
		return _failure("invalid_kind", "Job kind must be a safe identifier.")
	if source_fingerprint.is_empty() or source_fingerprint.length() > 256:
		return _failure("invalid_source", "Source fingerprint must contain 1 to 256 characters.")
	if _jobs.size() >= MAX_JOBS:
		return _failure("capacity_exceeded", "Job registry is at capacity.")
	var recipe_bytes: PackedByteArray = JSON.stringify(recipe).to_utf8_buffer()
	if recipe_bytes.size() > MAX_RECIPE_BYTES:
		return _failure("recipe_too_large", "Recipe exceeds the 64 KiB limit.")
	var runtime_value: Variant = budget.get("max_runtime_seconds", 60.0)
	var updates_value: Variant = budget.get("max_updates", 1000)
	if not (runtime_value is int or runtime_value is float) or not (updates_value is int or updates_value is float):
		return _failure("invalid_budget", "Budget requires numeric max_runtime_seconds and max_updates.")
	var runtime_limit: float = float(runtime_value)
	var update_limit: int = int(updates_value)
	if runtime_limit <= 0.0 or runtime_limit > MAX_RUNTIME_SECONDS or update_limit < 1 or update_limit > MAX_UPDATES:
		return _failure("invalid_budget", "Job budget is outside supported runtime or update limits.")
	_sequence += 1
	var id: String = "%s-%d-%d" % [job_namespace, Time.get_ticks_usec(), _sequence]
	var job: Dictionary = {"id": id, "namespace": job_namespace, "kind": kind,
		"source_fingerprint": source_fingerprint, "recipe": recipe.duplicate(true),
		"recipe_sha256": _sha256(recipe_bytes), "budget": {"max_runtime_seconds": runtime_limit,
		"max_updates": update_limit}, "state": "queued", "progress": 0.0,
		"revision": 1, "updates": 0, "created_msec": Time.get_ticks_msec(),
		"owner_token": _owner_token, "output_manifest": {}, "local_only": true,
		"execution_claim": "not_started"}
	_jobs[id] = job
	return _success("created", "Local job admitted; execution has not started.", job)


func advance(id: String, expected_revision: int, progress: float) -> Dictionary:
	var found: Dictionary = _get_job(id)
	if not found.get("ok", false):
		return found
	var job: Dictionary = found["job"]
	if not _is_active(job):
		return _failure("terminal_job", "Terminal jobs cannot advance.")
	if expected_revision != int(job["revision"]):
		return _failure("revision_conflict", "Job revision changed.", {"revision": job["revision"]})
	if progress < float(job["progress"]) or progress < 0.0 or progress > 1.0:
		return _failure("invalid_progress", "Progress must be nondecreasing and between 0 and 1.")
	if int(job["updates"]) >= int(job["budget"]["max_updates"]):
		return _interrupt_budget(job)
	if float(Time.get_ticks_msec() - int(job["created_msec"])) / 1000.0 > float(job["budget"]["max_runtime_seconds"]):
		return _interrupt_budget(job)
	job["state"] = "running"
	job["progress"] = progress
	job["updates"] = int(job["updates"]) + 1
	job["revision"] = int(job["revision"]) + 1
	job["execution_claim"] = "local_progress_reported"
	_jobs[id] = job
	return _success("advanced", "Local job progress recorded.", job)


func cancel(id: String) -> Dictionary:
	var found: Dictionary = _get_job(id)
	if not found.get("ok", false):
		return found
	var job: Dictionary = found["job"]
	if not _is_active(job):
		return _failure("terminal_job", "Terminal job state is immutable.")
	job["state"] = "cancelled"
	job["revision"] = int(job["revision"]) + 1
	job["execution_claim"] = "cancelled_before_publication"
	job["output_manifest"] = {}
	_jobs[id] = job
	return _success("cancelled", "Job cancelled; prior good output remains available.", job)


func finish(id: String, output_manifest: Dictionary) -> Dictionary:
	var found: Dictionary = _get_job(id)
	if not found.get("ok", false):
		return found
	var job: Dictionary = found["job"]
	if not _is_active(job):
		return _failure("terminal_job", "Terminal job state is immutable.")
	if output_manifest.is_empty() or JSON.stringify(output_manifest).to_utf8_buffer().size() > MAX_OUTPUT_BYTES:
		return _failure("invalid_output", "Output manifest must be nonempty and at most 64 KiB.")
	if int(job["updates"]) >= int(job["budget"]["max_updates"]) or float(Time.get_ticks_msec() - int(job["created_msec"])) / 1000.0 > float(job["budget"]["max_runtime_seconds"]):
		return _interrupt_budget(job)
	job["state"] = "completed"
	job["progress"] = 1.0
	job["revision"] = int(job["revision"]) + 1
	job["execution_claim"] = "manifest_committed_locally"
	job["output_manifest"] = output_manifest.duplicate(true)
	_jobs[id] = job
	_last_outputs[job["kind"]] = output_manifest.duplicate(true)
	return _success("completed", "Output manifest committed locally.", job)


func interrupt_ownerless() -> void:
	for id: Variant in _jobs.keys():
		var job: Dictionary = _jobs[id]
		if _is_active(job) and int(job["owner_token"]) != _owner_token:
			job["state"] = "interrupted"
			job["revision"] = int(job["revision"]) + 1
			job["execution_claim"] = "owner_lost"
			job["output_manifest"] = {}
			_jobs[id] = job


func observe(id: String = "") -> Dictionary:
	if not id.is_empty():
		var found: Dictionary = _get_job(id)
		if not found.get("ok", false):
			return found
		return {"ok": true, "code": "observed", "job": found["job"].duplicate(true),
			"last_good_output": _last_outputs.get(found["job"]["kind"], {}).duplicate(true)}
	var entries: Array[Dictionary] = []
	for job_id: Variant in _jobs.keys():
		entries.append(_jobs[job_id].duplicate(true))
	return {"ok": true, "code": "observed", "namespace": job_namespace,
		"jobs": entries, "last_good_outputs": _last_outputs.duplicate(true)}


func reset() -> Dictionary:
	var removed: int = _jobs.size()
	_jobs.clear()
	_last_outputs.clear()
	return {"ok": true, "code": "reset", "namespace": job_namespace, "removed": removed}


func _get_job(id: String) -> Dictionary:
	if not _jobs.has(id):
		return _failure("not_found", "Job is not present in this namespace.")
	var job: Dictionary = _jobs[id]
	if job.get("namespace", "") != job_namespace:
		return _failure("not_found", "Job is not present in this namespace.")
	return {"ok": true, "job": job}


func _is_active(job: Dictionary) -> bool:
	return job.get("state", "") == "queued" or job.get("state", "") == "running"


func _interrupt_budget(job: Dictionary) -> Dictionary:
	job["state"] = "budget_exceeded"
	job["revision"] = int(job["revision"]) + 1
	job["execution_claim"] = "budget_exceeded"
	job["output_manifest"] = {}
	_jobs[job["id"]] = job
	return _failure("budget_exceeded", "Job reached its configured runtime or update budget.",
		{"job": job.duplicate(true)})


func _success(code: String, message: String, job: Dictionary) -> Dictionary:
	return {"ok": true, "code": code, "message": message, "job": job.duplicate(true),
		"local_only": true}


func _failure(code: String, message: String, extra: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {"ok": false, "code": code, "message": message}
	result.merge(extra, true)
	return result


func _is_safe_id(value: String) -> bool:
	if value.is_empty() or value.length() > 64:
		return false
	for index: int in range(value.length()):
		var codepoint: int = value.unicode_at(index)
		var allowed: bool = (codepoint >= 48 and codepoint <= 57) or (codepoint >= 65 and codepoint <= 90) or (codepoint >= 97 and codepoint <= 122) or codepoint == 45 or codepoint == 95
		if not allowed or (index == 0 and (codepoint == 45 or codepoint == 95)):
			return false
	return true


func _sha256(bytes: PackedByteArray) -> String:
	var context: HashingContext = HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()
