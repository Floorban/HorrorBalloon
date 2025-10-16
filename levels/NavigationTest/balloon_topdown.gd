extends BalloonController
class_name BalloonTopDownController

@export var is_streering := false
@export var current_cam: Camera3D
var input_dir: Vector2

var current_velocity := Vector3.ZERO
var max_horizontal_speed := 10.0
var horizontal_acceleration := 1.0
var horizontal_damping := 0.98

var ang_velocity := 0.0

func _get_input() -> Vector3:
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	return (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func _update_horizontal_movement(delta: float):
	var direction = Vector3(_get_input().x, 0, _get_input().z).normalized()
	direction = direction.rotated(Vector3.UP, current_cam.global_rotation.y)

	var target_input_velocity = direction * max_horizontal_speed
	current_velocity = current_velocity.lerp(target_input_velocity, horizontal_acceleration * delta)
	# var total_velocity = current_velocity + _update_wind_influence(delta)
	global_position += current_velocity * delta


func _steering_movement(delta: float):
	var turn_speed := 0.5
	var forward_speed := 10.0
	var damping_rate := 0.95
	var angular_damping := 0.9
	
	var forward_input = Input.get_action_strength("forward") - Input.get_action_strength("backward")
	var turn_input = Input.get_action_strength("right") - Input.get_action_strength("left")

	if abs(turn_input) > 0.1:
		ang_velocity = lerp(ang_velocity, -turn_input * turn_speed, 1.0 * delta)
	else:
		ang_velocity = lerp(ang_velocity, 0.0, (1.0 - angular_damping) * delta)

	rotation.y += ang_velocity * delta

	var direction = -transform.basis.z * forward_input
	var target_velocity = direction * forward_speed

	if abs(forward_input) > 0.1:
		current_velocity = current_velocity.lerp(target_velocity, horizontal_acceleration * delta)
	else:
		current_velocity = current_velocity.lerp(Vector3.ZERO, (1.0 - damping_rate) * delta)

	global_position += current_velocity * delta

func _physics_process(delta: float) -> void:
	if not is_streering:
		_update_horizontal_movement(delta)
	else:
		_steering_movement(delta)
