extends Node3D

@onready var spring_arm: SpringArm3D = $SpringArm3D
@export var mouse_sensibility: float = 0.005

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x * mouse_sensibility
		rotation.y = wrapf(rotation.y, 0.0, TAU)
		
		rotation.x -= event.relative.y * mouse_sensibility
		rotation.x = clamp(rotation.x, -PI/2, PI/4)
	
	if event.is_action_pressed("wheel_up"):
		spring_arm.spring_length -= 1
	if event.is_action_pressed("wheel_down"):
		spring_arm.spring_length += 1
	
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
