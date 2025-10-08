extends Node
class_name BalloonInput

@export var oven: Oven
@export var strength: float = 10.0

func execute(percentage: float) -> void:
	if oven and oven.get_fuel_percentage() > 0.0:
		oven.consume_fuel(abs(percentage))

func get_vertical_input() -> float:
	return 0.0

func get_horizontal_input() -> Vector2:
	return Vector2.ZERO
