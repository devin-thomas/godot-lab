extends RefCounted

const IMAGE_SIZE: int = 16
const PCM_SAMPLES: int = 256
const PCM_RATE: int = 22050

var image_reference: Image
var audio_reference: AudioStreamWAV
var audio_reference_bytes: PackedByteArray = PackedByteArray()
var state_reference: Dictionary = {"entity": "lantern", "charge": 4, "active": true}


func configure() -> Dictionary:
	image_reference = _make_image()
	audio_reference_bytes = _make_pcm(220.0)
	audio_reference = _make_wav(audio_reference_bytes)
	return {"ok": true, "code": "REFERENCES_READY", "image_sha256": _image_hash(image_reference),
		"pcm_sha256": _sha256_bytes(audio_reference_bytes), "state_sha256": JSON.stringify(state_reference).sha256_text()}


func compare(channel: String, variant: String, tolerance: float) -> Dictionary:
	if channel == "image":
		var candidate: Image = image_reference.duplicate()
		if variant == "mutated":
			candidate.set_pixel(3, 5, Color(1.0, 0.02, 0.02, 1.0))
		elif variant != "baseline":
			return _failure("INVALID_VARIANT")
		var difference: float = _image_error(image_reference, candidate)
		return _comparison("pixels", difference, tolerance, _image_hash(image_reference), _image_hash(candidate),
			{"region": {"x": 0, "y": 0, "width": IMAGE_SIZE, "height": IMAGE_SIZE},
			"compared_pixels": IMAGE_SIZE * IMAGE_SIZE})
	if channel == "audio":
		var candidate_pcm: PackedByteArray
		match variant:
			"baseline": candidate_pcm = _make_pcm(220.0)
			"muted": candidate_pcm = _make_silence_bytes()
			"wrong_tone": candidate_pcm = _make_pcm(440.0)
			_: return _failure("INVALID_VARIANT")
		var candidate_stream: AudioStreamWAV = _make_wav(candidate_pcm)
		var difference: float = _pcm_error(audio_reference_bytes, candidate_pcm)
		return _comparison("audio_bytes", difference, tolerance, _sha256_bytes(audio_reference_bytes),
			_sha256_bytes(candidate_pcm), {"samples": PCM_SAMPLES, "mix_rate": candidate_stream.mix_rate,
			"capture_claim": false})
	if channel == "state":
		var candidate_state: Dictionary = state_reference.duplicate(true)
		if variant == "mutated":
			candidate_state["charge"] = 3
		elif variant != "baseline":
			return _failure("INVALID_VARIANT")
		var difference: float = 0.0 if candidate_state == state_reference else 1.0
		return _comparison("semantic_state", difference, tolerance, JSON.stringify(state_reference).sha256_text(),
			JSON.stringify(candidate_state).sha256_text(), {"reference": state_reference.duplicate(true), "candidate": candidate_state})
	return _failure("UNKNOWN_CHANNEL")


func update_reference(channel: String, variant: String) -> Dictionary:
	if channel == "image" and variant in ["baseline", "mutated"]:
		image_reference = _make_image()
		if variant == "mutated":
			image_reference.set_pixel(3, 5, Color(1.0, 0.02, 0.02, 1.0))
	elif channel == "audio" and variant in ["baseline", "muted", "wrong_tone"]:
		audio_reference_bytes = _make_silence_bytes() if variant == "muted" else _make_pcm(440.0 if variant == "wrong_tone" else 220.0)
		audio_reference = _make_wav(audio_reference_bytes)
	elif channel == "state" and variant in ["baseline", "mutated"]:
		state_reference = {"entity": "lantern", "charge": 3 if variant == "mutated" else 4, "active": true}
	else:
		return _failure("INVALID_VARIANT")
	return {"ok": true, "code": "REFERENCE_UPDATED_AFTER_REVIEW", "channel": channel}


func _make_image() -> Image:
	var image: Image = Image.create(IMAGE_SIZE, IMAGE_SIZE, false, Image.FORMAT_RGBA8)
	for y: int in range(IMAGE_SIZE):
		for x: int in range(IMAGE_SIZE):
			var wave: float = float((x * 3 + y * 5) % 16) / 15.0
			image.set_pixel(x, y, Color(0.08 + wave * 0.2, 0.35 + wave * 0.3, 0.42 + wave * 0.2, 1.0))
	return image


func _make_pcm(frequency: float) -> PackedByteArray:
	var bytes: PackedByteArray = PackedByteArray()
	for index: int in range(PCM_SAMPLES):
		var sample: int = int(sin(TAU * frequency * float(index) / float(PCM_RATE)) * 10000.0)
		bytes.append(sample & 255)
		bytes.append((sample >> 8) & 255)
	return bytes


func _make_silence_bytes() -> PackedByteArray:
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(PCM_SAMPLES * 2)
	return bytes


func _make_wav(bytes: PackedByteArray) -> AudioStreamWAV:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = PCM_RATE
	stream.stereo = false
	stream.data = bytes.duplicate()
	return stream


func _image_error(reference: Image, candidate: Image) -> float:
	var total_error: float = 0.0
	for y: int in range(IMAGE_SIZE):
		for x: int in range(IMAGE_SIZE):
			var expected: Color = reference.get_pixel(x, y)
			var actual: Color = candidate.get_pixel(x, y)
			total_error += absf(expected.r - actual.r) + absf(expected.g - actual.g) + absf(expected.b - actual.b) + absf(expected.a - actual.a)
	return total_error / float(IMAGE_SIZE * IMAGE_SIZE * 4)


func _pcm_error(reference: PackedByteArray, candidate: PackedByteArray) -> float:
	if reference.size() != candidate.size() or reference.is_empty():
		return 1.0
	var total_error: float = 0.0
	for offset: int in range(0, reference.size(), 2):
		var expected: int = _signed_sample(reference[offset], reference[offset + 1])
		var actual: int = _signed_sample(candidate[offset], candidate[offset + 1])
		total_error += absf(float(expected - actual)) / 32768.0
	return total_error / float(reference.size() / 2)


func _signed_sample(low: int, high: int) -> int:
	var value: int = low | (high << 8)
	return value - 65536 if value >= 32768 else value


func _image_hash(image: Image) -> String:
	return _sha256_bytes(image.get_data())


func _sha256_bytes(bytes: PackedByteArray) -> String:
	var hashing: HashingContext = HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(bytes)
	return hashing.finish().hex_encode()


func _comparison(metric: String, difference: float, tolerance: float, reference_hash: String,
		candidate_hash: String, details: Dictionary) -> Dictionary:
	return {"ok": difference <= tolerance, "code": "WITHIN_TOLERANCE" if difference <= tolerance else "DIFFERENCE_EXCEEDED",
		"metric": metric, "difference": difference, "tolerance": tolerance,
		"reference_sha256": reference_hash, "candidate_sha256": candidate_hash, "details": details}


func _failure(code: String) -> Dictionary:
	return {"ok": false, "code": code}
