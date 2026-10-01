extends RefCounted

const MAX_ELEMENTS: int = 4096
const WORK_PER_ELEMENT: int = 16

var _mutex: Mutex = Mutex.new()
var _task_id: int = -1
var _generation: int = 0
var _running: bool = false
var _task_joined: bool = false
var _cancel_requested: bool = false
var _progress: float = 0.0
var _result: Dictionary = {}


func start(seed_value: int, element_count: int) -> Dictionary:
	if _running:
		return {"ok": false, "code": "TASK_ACTIVE"}
	if element_count < 64 or element_count > MAX_ELEMENTS:
		return {"ok": false, "code": "INVALID_BUDGET"}
	_generation += 1
	_cancel_requested = false
	_progress = 0.0
	_result.clear()
	var task_generation: int = _generation
	_task_id = WorkerThreadPool.add_task(Callable(self, "_run_worker").bind(task_generation,
		seed_value, element_count), false, "Thread Mill bounded integer fixture")
	if _task_id < 0:
		return {"ok": false, "code": "WORKER_UNAVAILABLE"}
	_running = true
	_task_joined = false
	return {"ok": true, "code": "STARTED", "task_id": _task_id, "local_only": true}


func status() -> Dictionary:
	if not _running:
		return {"running": false, "done": not _result.is_empty(), "progress": _progress,
			"result": _result.duplicate(true)}
	if not WorkerThreadPool.is_task_completed(_task_id):
		return {"running": true, "done": false, "progress": _locked_progress()}
	var wait_error: Error = WorkerThreadPool.wait_for_task_completion(_task_id)
	if wait_error != OK:
		return {"running": true, "done": false, "progress": _locked_progress(),
			"error": wait_error}
	_running = false
	_task_id = -1
	_task_joined = true
	return {"running": false, "done": not _result.is_empty(), "progress": _locked_progress(),
		"result": _locked_result()}


func cancel_and_discard() -> Dictionary:
	var had_active_task: bool = _running
	var wait_error: Error = OK
	if _running:
		_mutex.lock()
		_cancel_requested = true
		_mutex.unlock()
		wait_error = WorkerThreadPool.wait_for_task_completion(_task_id)
		if wait_error != OK:
			return {"ok": false, "code": "JOIN_FAILED", "error": wait_error}
		_running = false
		_task_id = -1
		_task_joined = true
	_mutex.lock()
	var progress_value: float = _progress
	var discarded_result: bool = not _result.is_empty()
	var task_joined: bool = _task_joined
	_result.clear()
	_progress = 0.0
	_task_joined = false
	_mutex.unlock()
	if not had_active_task and not discarded_result:
		return {"ok": false, "code": "NO_ACTIVE_TASK"}
	return {"ok": true, "code": "CANCELLED_AND_DISCARDED", "progress_at_cancel": progress_value,
		"joined": task_joined, "discarded_result": discarded_result}


func clear() -> Dictionary:
	if _running:
		return {"ok": false, "code": "TASK_MUST_BE_JOINED"}
	_result.clear()
	_progress = 0.0
	_task_joined = false
	return {"ok": true, "code": "CLEARED"}


func reference_checksum(seed_value: int, element_count: int) -> int:
	if element_count < 0 or element_count > MAX_ELEMENTS:
		return -1
	var value: int = posmod(seed_value, 4294967296)
	for index: int in range(element_count):
		for pass_index: int in range(WORK_PER_ELEMENT):
			value = posmod(value * 1664525 + 1013904223 + index + pass_index, 4294967296)
	return value


func _run_worker(task_generation: int, seed_value: int, element_count: int) -> void:
	var value: int = posmod(seed_value, 4294967296)
	var cancelled: bool = false
	for index: int in range(element_count):
		for pass_index: int in range(WORK_PER_ELEMENT):
			value = posmod(value * 1664525 + 1013904223 + index + pass_index, 4294967296)
		if index % 64 == 0:
			_mutex.lock()
			cancelled = task_generation != _generation or _cancel_requested
			_progress = float(index + 1) / float(element_count)
			_mutex.unlock()
			if cancelled:
				break
	_mutex.lock()
	if task_generation == _generation and not _cancel_requested and not cancelled:
		_result = {"checksum": value, "elements": element_count, "seed": seed_value,
			"thread_pool_task": true}
		_progress = 1.0
	_mutex.unlock()


func _locked_progress() -> float:
	_mutex.lock()
	var result: float = _progress
	_mutex.unlock()
	return result


func _locked_result() -> Dictionary:
	_mutex.lock()
	var result: Dictionary = _result.duplicate(true)
	_mutex.unlock()
	return result
