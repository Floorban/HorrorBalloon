extends PlayerController

@export var current_cam: Camera3D
@export var move_speed := 8.0
@export var damping := 0.9
@export var rotate_to_direction := true

func _physics_process(delta: float) -> void:
	var input_vector = Input.get_vector("left", "right", "forward", "backward")
	
	direction = Vector3(input_vector.x, 0, input_vector.y).normalized()
	direction = direction.rotated(Vector3.UP, current_cam.global_rotation.y)
	var target_velocity = direction * move_speed
	velocity = velocity.lerp(target_velocity, acceleration * delta)

	if direction == Vector3.ZERO:
		velocity *= damping

	move_and_slide()

	if rotate_to_direction and direction != Vector3.ZERO:
		var target_yaw = atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, 10.0 * delta)
