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

func get_horizontal_input() -> Vector2:
	# TODO: now it's referencing the same wheel since rotation is only clockwise and counter-clockwise
	var parent_forward: Vector3 = -get_parent().global_transform.basis.z
	var forward_2d = Vector2(parent_forward.x, parent_forward.z).normalized()
	return forward_2d * current_forward

func get_rotation_input() -> float:
	return current_rotation
