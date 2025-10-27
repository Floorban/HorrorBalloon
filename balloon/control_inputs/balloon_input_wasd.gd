extends BalloonInput

@onready var player : PlayerController = get_tree().get_first_node_in_group("player")

@export var forward_back_threshold : float
@export var left_right_threshold : float

var current_forward := 0.0
var current_right := 0.0

func execute(percentage: float, primary: bool) -> void:
	super.execute(percentage, primary)
	if primary:
		if abs(percentage) > forward_back_threshold:
			current_forward = percentage * intensity
		else:
			current_forward = 0.0
	else:
		if abs(percentage) > left_right_threshold:
			current_right = percentage * intensity
		else:
			current_right = 0.0

func get_horizontal_input() -> Vector2:
	if not player:
		return Vector2.ZERO
	var forward = -player.global_transform.basis.z
	var right = player.global_transform.basis.x
	var forward_2d = Vector2(forward.x, forward.z).normalized()
	var right_2d = Vector2(right.x, right.z).normalized()

	return (forward_2d * current_forward) + (right_2d * current_right)
