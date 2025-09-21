extends RigidBody3D
class_name BalloonController

@export var lift_force := 2.0
@export var down_force := 2.0
@export var horizontal_force := 2.0

@onready var mesh: Node3D = $Mesh
@export var max_tilt_angle := 8.0
var tilt_tween : Tween

var move_threshold := 0.1
var tilt_threshold := 0.005
var tilt_damping := 0.5

var player : PlayerController
var prev_velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float):
	# vertical movement
	if Input.is_action_pressed("primary"):
		apply_central_force(Vector3.UP * lift_force)
	elif Input.is_action_pressed("secondary"):
		apply_central_force(Vector3.DOWN * down_force)
	# horizontal movement based on player position
	_apply_horizontal_force()

func _player_relative_pos() -> Vector3:
	if not player:
		return Vector3.ZERO
	else:
		return player.global_position - global_position

func _apply_horizontal_force():
	var rel_pos = _player_relative_pos()

	# normalize player position into -1..1 range grid
	var x_dir = clamp(rel_pos.x, -1.0, 1.0)
	var z_dir = clamp(rel_pos.z, -1.0, 1.0)

	var force_vec = Vector3(x_dir, 0.0, z_dir).normalized()
	if force_vec.length() > tilt_threshold:
		var target_x_rot = z_dir * max_tilt_angle
		var target_z_rot = -x_dir * max_tilt_angle
		_tilt_to(Vector3(deg_to_rad(target_x_rot), 0.0, deg_to_rad(target_z_rot)))

		if force_vec.length() > move_threshold:
			apply_central_force(force_vec * horizontal_force)
	else:
		_tilt_to(Vector3.ZERO)

func _tilt_to(target_rot: Vector3):
	if tilt_tween:
		tilt_tween.kill()

	tilt_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tilt_tween.tween_property(mesh, "rotation", target_rot, tilt_damping)

	if player:
		player.apply_sway(target_rot)
