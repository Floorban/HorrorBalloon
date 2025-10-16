extends BalloonInput

var current_vertical: float = 0.0

func execute(percentage: float, primary: bool) -> void:
	super.execute(percentage, primary)
	if percentage > 0:
		current_vertical += intensity * get_process_delta_time()
	elif percentage < 0:
		current_vertical -= intensity * get_process_delta_time()
	else:
		current_vertical = 0.0

func get_vertical_input() -> float:
	return clamp(current_vertical,-1,1)
