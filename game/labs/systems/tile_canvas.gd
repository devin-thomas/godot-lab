extends SubViewportContainer
signal paint_requested(x: int, y: int, tile: int)
var selected_brush: int = 1

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cell := Vector2i(floori(event.position.x * 8.0 / size.x), floori(event.position.y * 5.0 / size.y))
		if cell.x >= 0 and cell.x < 8 and cell.y >= 0 and cell.y < 5:
			paint_requested.emit(cell.x, cell.y, selected_brush)
			accept_event()
