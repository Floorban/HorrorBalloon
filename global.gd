extends Node

var current_level := 1
var attempts := 1

func get_current_level() -> int:
	return current_level

func set_current_level(level: int) -> void:
	current_level = level