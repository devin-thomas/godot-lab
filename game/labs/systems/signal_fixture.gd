extends Node
signal pulse(source: String, sequence: int)
var sequence: int = 0

func trigger(source: String) -> void:
	sequence += 1
	pulse.emit(source, sequence)
