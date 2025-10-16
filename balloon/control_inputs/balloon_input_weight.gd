extends BalloonInput

var current_forward: float = 0.0

func execute(percentage: float, primary: bool) -> void:
	super.execute(percentage, primary)
	current_forward = percentage * intensity

func get_horizontal_input() -> Vector2:
	var parent_forward: Vector3 = -get_parent().global_transform.basis.z
	var forward_2d = Vector2(parent_forward.x, parent_forward.z).normalized()
	return forward_2d * current_forward
