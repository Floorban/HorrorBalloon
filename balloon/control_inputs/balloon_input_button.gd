extends BalloonInput

var current_vertical: float = 0.0

func execute(percentage: float) -> void:
	oven.consume_fuel(abs(percentage) * 0.01)
	if percentage > 0:
		current_vertical += strength * get_process_delta_time()
	elif percentage < 0:
		current_vertical -= strength * get_process_delta_time()
	else:
		current_vertical = 0.0

func get_vertical_input() -> float:
	return clamp(current_vertical,-1,1)

func get_horizontal_input() -> Vector2:
	return Vector2.ZERO
