extends Node
class_name BalloonInput

@export var strength: float = 10.0

func get_vertical_input() -> float:
	return 0.0

func get_horizontal_input() -> Vector2:
	return Vector2.ZERO