extends PlayerController

@export var grid_size := 1.0
@export var rotate_speed := 10.0

@onready var wall_check_up: RayCast3D = $WallCheck_Up
@onready var wall_check_down: RayCast3D = $WallCheck_Down
@onready var wall_check_left: RayCast3D = $WallCheck_Left
@onready var wall_check_right: RayCast3D = $WallCheck_Right

var target_rotation_y := 0.0

func _ready():
	target_rotation_y = rotation.y

func _physics_process(delta: float) -> void:
	rotation.y = lerp_angle(rotation.y, target_rotation_y, rotate_speed * delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		target_rotation_y += deg_to_rad(90)
		return
	elif event.is_action_pressed("ui_right"):
		target_rotation_y -= deg_to_rad(90)
		return

	if event.is_action_pressed("forward") and not wall_check_up.is_colliding():
		_snap_move(-transform.basis.z)
	elif event.is_action_pressed("backward") and not wall_check_down.is_colliding():
		_snap_move(transform.basis.z)
	elif event.is_action_pressed("left") and not wall_check_left.is_colliding():
		_snap_move(-transform.basis.x)
	elif event.is_action_pressed("right") and not wall_check_right.is_colliding():
		_snap_move(transform.basis.x)

func _snap_move(_direction: Vector3):
	_direction.y = 0
	_direction = _direction.normalized()
	global_position += _direction * grid_size
