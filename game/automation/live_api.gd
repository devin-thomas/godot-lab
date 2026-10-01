extends Node

const MAX_CLIENTS: int = 8
const MAX_HEADER_BYTES: int = 8192
const MAX_BODY_BYTES: int = 65536
const MAX_RESPONSE_BYTES: int = 262144
const CLIENT_DEADLINE_MS: int = 5000

var _server: TCPServer = TCPServer.new()
var _clients: Array[Dictionary] = []
var _bus: RefCounted
var _observer: Callable
var _token: PackedByteArray = []
var _run_id: String = ""
var _bound_port: int = 0
var _crypto: Crypto = Crypto.new()


func configure(bus: RefCounted, observer: Callable, port: int = 0, token: String = "") -> Dictionary:
	stop()
	if token.is_empty() or token.length() > 512 or token.contains("\r") or token.contains("\n"):
		return {"ok": false, "code": "TOKEN_REQUIRED"}
	if bus == null or not bus.has_method("submit") or not bus.has_method("describe") or not bus.has_method("events_since") or not observer.is_valid() or port < 0 or port > 65535:
		return {"ok": false, "code": "INVALID_CONFIGURATION"}
	var random: PackedByteArray = _crypto.generate_random_bytes(16)
	if random.size() != 16:
		return {"ok": false, "code": "IDENTITY_UNAVAILABLE"}
	var error: Error = _server.listen(port, "127.0.0.1")
	if error != OK:
		return {"ok": false, "code": "BIND_FAILED", "error": error}
	_bus = bus
	_observer = observer
	_token = ("Bearer " + token).to_utf8_buffer()
	_run_id = random.hex_encode()
	_bound_port = _server.get_local_port()
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)
	return {"ok": true, "code": "LISTENING", "bound_port": _bound_port, "run_id": _run_id, "service": "godot-lab-live"}


func observation() -> Dictionary:
	return {"state": "listening" if _server.is_listening() else "stopped", "bound_port": _bound_port, "run_id": _run_id, "client_count": _clients.size()}


func stop() -> void:
	set_process(false)
	_server.stop()
	for client: Dictionary in _clients:
		var peer: StreamPeerTCP = client["peer"]
		peer.disconnect_from_host()
	_clients.clear()
	_token.clear()
	_bus = null
	_observer = Callable()
	_bound_port = 0
	_run_id = ""


func _exit_tree() -> void:
	stop()


func _process(_delta: float) -> void:
	if not _server.is_listening():
		return
	# Admission and per-frame work stay bounded even under a connection flood.
	for _index: int in range(MAX_CLIENTS):
		if not _server.is_connection_available():
			break
		var peer: StreamPeerTCP = _server.take_connection()
		if peer == null:
			break
		if _clients.size() >= MAX_CLIENTS:
			peer.disconnect_from_host()
			continue
		peer.set_no_delay(true)
		_clients.append({"peer": peer, "buffer": PackedByteArray(), "started": Time.get_ticks_msec(), "headers": {}, "header_end": -1, "body_length": 0, "responding": false, "output": PackedByteArray(), "sent": 0})
	for index: int in range(_clients.size() - 1, -1, -1):
		var client: Dictionary = _clients[index]
		var peer: StreamPeerTCP = client["peer"]
		if peer.poll() != OK or peer.get_status() != StreamPeerTCP.STATUS_CONNECTED or Time.get_ticks_msec() - int(client["started"]) > CLIENT_DEADLINE_MS:
			peer.disconnect_from_host()
			_clients.remove_at(index)
			continue
		if client["responding"]:
			if _flush(client):
				peer.disconnect_from_host()
				_clients.remove_at(index)
			continue
		_receive(client)


func _receive(client: Dictionary) -> void:
	var peer: StreamPeerTCP = client["peer"]
	var available: int = peer.get_available_bytes()
	if available <= 0:
		return
	var buffer: PackedByteArray = client["buffer"]
	if buffer.size() + available > MAX_HEADER_BYTES + MAX_BODY_BYTES:
		_respond(client, 413, {"ok": false, "code": "REQUEST_TOO_LARGE"})
		return
	var received: Array = peer.get_partial_data(mini(available, 16384))
	if received[0] != OK:
		peer.disconnect_from_host()
		return
	buffer.append_array(received[1])
	client["buffer"] = buffer
	if int(client["header_end"]) < 0:
		var end: int = buffer.get_string_from_ascii().find("\r\n\r\n")
		if end < 0:
			if buffer.size() > MAX_HEADER_BYTES:
				_respond(client, 431, {"ok": false, "code": "HEADER_TOO_LARGE"})
			return
		if end + 4 > MAX_HEADER_BYTES:
			_respond(client, 431, {"ok": false, "code": "HEADER_TOO_LARGE"})
			return
		var parsed: Dictionary = _parse_headers(buffer.slice(0, end))
		if not parsed["ok"]:
			_respond(client, int(parsed.get("status", 400)), {"ok": false, "code": parsed["code"]})
			return
		client["headers"] = parsed
		client["header_end"] = end + 4
		client["body_length"] = parsed["length"]
		if parsed["path"] != "/health" and not _authorized(parsed["headers"]):
			_respond(client, 401, {"ok": false, "code": "UNAUTHORIZED"})
			return
	var body_start: int = client["header_end"]
	var body_length: int = client["body_length"]
	if buffer.size() < body_start + body_length:
		return
	if buffer.size() != body_start + body_length:
		_respond(client, 400, {"ok": false, "code": "AMBIGUOUS_REQUEST"})
		return
	_dispatch(client, client["headers"], buffer.slice(body_start))


func _parse_headers(bytes: PackedByteArray) -> Dictionary:
	for byte: int in bytes:
		if byte != 9 and byte != 10 and byte != 13 and (byte < 32 or byte > 126):
			return {"ok": false, "code": "INVALID_HEADER"}
	var lines: PackedStringArray = bytes.get_string_from_ascii().split("\r\n")
	var first: PackedStringArray = lines[0].split(" ")
	if first.size() != 3 or first[0] not in ["GET", "POST"] or first[2] != "HTTP/1.1":
		return {"ok": false, "code": "INVALID_REQUEST_LINE"}
	var path: String = first[1]
	if not path.begins_with("/") or path.length() > 256 or path.contains("..") or path.contains("%") or path.contains("\\") or path.contains("#"):
		return {"ok": false, "code": "INVALID_PATH"}
	var headers: Dictionary = {}
	if lines.size() > 65:
		return {"ok": false, "code": "HEADER_TOO_LARGE", "status": 431}
	for index: int in range(1, lines.size()):
		var line: String = lines[index]
		var colon: int = line.find(":")
		if colon <= 0 or line.begins_with(" ") or line.begins_with("\t") or line.contains("\r") or line.contains("\n"):
			return {"ok": false, "code": "INVALID_HEADER"}
		var name: String = line.substr(0, colon).to_lower()
		for character: String in name:
			if character not in "abcdefghijklmnopqrstuvwxyz0123456789-":
				return {"ok": false, "code": "INVALID_HEADER"}
		if headers.has(name):
			return {"ok": false, "code": "DUPLICATE_HEADER"}
		headers[name] = line.substr(colon + 1).strip_edges()
	if headers.has("transfer-encoding") or headers.has("expect"):
		return {"ok": false, "code": "UNSUPPORTED_TRANSFER"}
	if not headers.has("host"):
		return {"ok": false, "code": "HOST_REQUIRED"}
	var length_text: String = headers.get("content-length", "0")
	if length_text.is_empty() or length_text.length() > 10:
		return {"ok": false, "code": "INVALID_CONTENT_LENGTH"}
	for character: String in length_text:
		if character not in "0123456789":
			return {"ok": false, "code": "INVALID_CONTENT_LENGTH"}
	var length: int = length_text.to_int()
	if length > MAX_BODY_BYTES:
		return {"ok": false, "code": "REQUEST_TOO_LARGE", "status": 413}
	if first[0] == "POST" and not headers.has("content-length"):
		return {"ok": false, "code": "LENGTH_REQUIRED"}
	if first[0] == "GET" and length != 0:
		return {"ok": false, "code": "UNEXPECTED_BODY"}
	return {"ok": true, "code": "OK", "method": first[0], "path": path, "headers": headers, "length": length}


func _authorized(headers: Dictionary) -> bool:
	var supplied: String = headers.get("authorization", "")
	return _crypto.constant_time_compare(_token, supplied.to_utf8_buffer())


func _dispatch(client: Dictionary, request: Dictionary, body: PackedByteArray) -> void:
	var method: String = request["method"]
	var path: String = request["path"]
	if method == "GET" and path == "/health":
		_respond(client, 200, {"ok": true, "code": "OK", "service": "godot-lab-live", "protocol_version": 1, "run_id": _run_id})
	elif method == "GET" and path == "/v1/operations":
		_respond(client, 200, {"ok": true, "code": "OK", "run_id": _run_id, "operations": _bus.describe()})
	elif method == "GET" and path == "/v1/state":
		var state: Variant = _observer.call()
		if not state is Dictionary:
			_respond(client, 500, {"ok": false, "code": "INVALID_OBSERVATION"})
		else:
			_respond(client, 200, {"ok": true, "code": "OK", "run_id": _run_id, "state": state})
	elif method == "GET" and (path == "/v1/events" or path.begins_with("/v1/events?after=")):
		var cursor_text: String = "0" if path == "/v1/events" else path.trim_prefix("/v1/events?after=")
		if cursor_text.length() > 16 or not cursor_text.is_valid_int() or cursor_text.begins_with("+") or cursor_text.to_int() < 0:
			_respond(client, 400, {"ok": false, "code": "INVALID_CURSOR"})
			return
		var events: Dictionary = _bus.events_since(cursor_text.to_int())
		events["run_id"] = _run_id
		_respond(client, 200 if events["ok"] else 409, events)
	elif method == "POST" and path == "/v1/operations":
		var headers: Dictionary = request["headers"]
		if headers.get("content-type", "").split(";")[0].strip_edges().to_lower() != "application/json" or not _valid_utf8(body):
			_respond(client, 400, {"ok": false, "code": "INVALID_JSON"})
			return
		var text: String = body.get_string_from_utf8()
		var json: JSON = JSON.new()
		if json.parse(text) != OK or not json.data is Dictionary:
			_respond(client, 400, {"ok": false, "code": "INVALID_JSON"})
			return
		if not _unique_json_keys(text):
			_respond(client, 400, {"ok": false, "code": "DUPLICATE_JSON_KEY"})
			return
		var receipt: Dictionary = _bus.submit(json.data)
		receipt["run_id"] = _run_id
		_respond(client, 200 if receipt["ok"] else 409, receipt)
	else:
		_respond(client, 404, {"ok": false, "code": "NOT_FOUND"})


func _respond(client: Dictionary, status: int, payload: Dictionary) -> void:
	var body: PackedByteArray = JSON.stringify(payload).to_utf8_buffer()
	if body.size() > MAX_RESPONSE_BYTES:
		status = 500
		body = JSON.stringify({"ok": false, "code": "RESPONSE_TOO_LARGE"}).to_utf8_buffer()
	var header: String = "HTTP/1.1 %d Result\r\nContent-Type: application/json\r\nContent-Length: %d\r\nConnection: close\r\nCache-Control: no-store\r\n\r\n" % [status, body.size()]
	var output: PackedByteArray = header.to_ascii_buffer()
	output.append_array(body)
	client["output"] = output
	client["responding"] = true


func _flush(client: Dictionary) -> bool:
	var peer: StreamPeerTCP = client["peer"]
	var output: PackedByteArray = client["output"]
	var sent: int = client["sent"]
	var result: Array = peer.put_partial_data(output.slice(sent, mini(sent + 16384, output.size())))
	if result[0] != OK:
		return true
	client["sent"] = sent + int(result[1])
	return client["sent"] >= output.size()


func _valid_utf8(bytes: PackedByteArray) -> bool:
	var index: int = 0
	while index < bytes.size():
		var first: int = bytes[index]
		if first < 128:
			index += 1
			continue
		var count: int = 2 if first >= 194 and first <= 223 else (3 if first >= 224 and first <= 239 else (4 if first >= 240 and first <= 244 else 0))
		if count == 0 or index + count > bytes.size():
			return false
		var second: int = bytes[index + 1]
		if (first == 224 and second < 160) or (first == 237 and second >= 160) or (first == 240 and second < 144) or (first == 244 and second >= 144):
			return false
		for offset: int in range(1, count):
			if bytes[index + offset] < 128 or bytes[index + offset] > 191:
				return false
		index += count
	return true


func _unique_json_keys(text: String) -> bool:
	var frames: Array[Dictionary] = []
	var index: int = 0
	while index < text.length():
		var character: String = text[index]
		if character in ["{", "["]:
			if frames.size() >= 16:
				return false
			frames.append({"object": character == "{", "keys": {}})
		elif character in ["}", "]"]:
			if frames.is_empty():
				return false
			frames.pop_back()
		elif character == "\"":
			var start: int = index
			index += 1
			while index < text.length():
				if text[index] == "\\":
					index += 2
					continue
				if text[index] == "\"":
					break
				index += 1
			if index >= text.length():
				return false
			var after: int = index + 1
			while after < text.length() and text[after] in [" ", "\t", "\r", "\n"]:
				after += 1
			if after < text.length() and text[after] == ":" and not frames.is_empty() and frames[-1]["object"]:
				var key: Variant = JSON.parse_string(text.substr(start, index - start + 1))
				if not key is String or frames[-1]["keys"].has(key):
					return false
				frames[-1]["keys"][key] = true
		index += 1
	return frames.is_empty()
