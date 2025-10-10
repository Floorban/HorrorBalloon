extends BalloonInput

var current_forward: float = 0.0
var current_rotation: float = 0.0

func execute(percentage: float, primary: bool) -> void:
	super.execute(percentage, primary)
	if primary:
		if abs(percentage - 0.5) > 0.05:
			current_rotation = (percentage - 0.5) * intensity
		else:
			current_rotation = 0.0
	else:
		current_forward = percentage * intensity
		print(current_forward)

func get_horizontal_input() -> Vector2:
	return Vector2(-current_forward,0.0)

func get_rotation_input() -> float:
	return current_rotation
