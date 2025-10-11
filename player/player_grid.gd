extends PlayerController

@export var canMove := true
@export var move_speed := 8.0
@export var rotation_speed := 6.0
@export var grid_boundary := 1
@export var grid_size := 1

var current_position: Vector2i = Vector2i.ZERO
var target_rotation_y: float
var facing_dir: Vector3 = Vector3.FORWARD

@onready var wall_check_up: RayCast3D = $WallCheck_Up
@onready var wall_check_down: RayCast3D = $WallCheck_Down
@onready var wall_check_left: RayCast3D = $WallCheck_Left
@onready var wall_check_right: RayCast3D = $WallCheck_Right

func _ready() -> void:
	target_rotation_y = rotation.y
	update_facing_dir()

func _physics_process(delta: float) -> void:
	if is_dead: return
	update_player_state()
	update_player_verticle(delta)
	grid_input()
	grid_rotate(delta)

func grid_input() -> void:
	if Input.is_action_just_pressed("ui_up") and not wall_check_up.is_colliding():
		grid_move(Vector2(0, -1)*facing_dir.z)
	elif Input.is_action_just_pressed("ui_down") and not wall_check_down.is_colliding():
		grid_move(Vector2(0, -1)*facing_dir.z)
	elif Input.is_action_just_pressed("ui_left") and not wall_check_left.is_colliding():
		grid_move(Vector2(-1, 0)*facing_dir.x)
	elif Input.is_action_just_pressed("ui_right") and not wall_check_right.is_colliding():
		grid_move(Vector2(1, 0)*facing_dir.x)

	if Input.is_action_just_pressed("left"):
		target_rotation_y += deg_to_rad(90)
		update_facing_dir()
	elif Input.is_action_just_pressed("right"):
		target_rotation_y -= deg_to_rad(90)
		update_facing_dir()

func grid_move(dir: Vector2) -> void:
	global_position += Vector3(dir.x * grid_size, 0, dir.y * grid_size)

func grid_rotate(delta: float) -> void:
	rotation.y = lerp_angle(rotation.y, target_rotation_y, delta * rotation_speed)

func update_facing_dir() -> void:
	facing_dir = (Basis(Vector3.UP, target_rotation_y) * Vector3.FORWARD).normalized()
