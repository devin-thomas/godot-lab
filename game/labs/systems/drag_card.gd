extends Button
## Pointer dragging and keyboard activation submit the same staged operation.
signal stage_requested(payload: String, target: String)
var payload_id: String = "sea-glass"
var slot_id: String = "material-slot"
var accepts_drop: bool = false

func _get_drag_data(_at: Vector2) -> Variant:
	if accepts_drop:
		return null
	var preview := Label.new()
	preview.text = "Sea-glass material"
	set_drag_preview(preview)
	return {"type": "lab-material", "id": payload_id}

func _can_drop_data(_at: Vector2, data: Variant) -> bool:
	return accepts_drop and data is Dictionary and data.get("type") == "lab-material" and data.get("id") == "sea-glass"

func _drop_data(_at: Vector2, data: Variant) -> void:
	stage_requested.emit(String(data["id"]), slot_id)
