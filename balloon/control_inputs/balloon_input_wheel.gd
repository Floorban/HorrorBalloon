extends BalloonInput

var current_rotation: float = 0.0

func execute(percentage: float) -> void:
	super.execute(percentage)
	if abs(percentage - 0.5) > 0.1:
		current_rotation = (percentage - 0.5) * insensity
	else:
		current_rotation = 0.0

func get_rotation_input() -> float:
	return current_rotation
