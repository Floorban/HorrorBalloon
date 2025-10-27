extends Node
class_name BalloonInput

@export var balloon: BalloonController
@export var intensity: float = 10.0

func execute(percentage: float, primary: bool) -> void:
	if balloon and balloon.get_balloon_fuel():
		balloon.consume_fuel(abs(percentage)*0.01)

func get_vertical_input() -> float:
	return 0.0

func get_horizontal_input() -> Vector2:
	return Vector2.ZERO

func get_rotation_input() -> float:
	return 0.0
