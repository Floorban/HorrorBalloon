extends RigidBody3D
class_name BalloonController

@export var lift_force := 10.0
@export var down_force := 1.0
@export var horizontal_force := 1.0

@onready var mesh: Node3D = $Mesh
@export var max_tilt_angle := 25.0
var tilt_tween : Tween

var player : PlayerController

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float):
	# vertical movement
	if Input.is_action_pressed("heat_up"):
		apply_central_force(Vector3.UP * lift_force)
	elif Input.is_action_pressed("cooldown"):
		apply_central_force(Vector3.DOWN * down_force)
	# horizontal movement based on player position
	_apply_horizontal_force()

func _player_relative_pos() -> Vector3:
	return player.global_position - global_position

func _apply_horizontal_force():
	var rel_pos = _player_relative_pos()

	# normalize player position into -1..1 range grid
	var x_dir = clamp(rel_pos.x, -1.0, 1.0)
	var z_dir = clamp(rel_pos.z, -1.0, 1.0)

	var force_vec = Vector3(x_dir, 0.0, z_dir).normalized()
	if force_vec.length() > 0.1:
		apply_central_force(force_vec * horizontal_force)

		var target_x_rot = z_dir * max_tilt_angle
		var target_z_rot = -x_dir * max_tilt_angle
		_tilt_to(Vector3(deg_to_rad(target_x_rot), 0.0, deg_to_rad(target_z_rot)))
	else:
		_tilt_to(Vector3.ZERO)

func _tilt_to(target_rot: Vector3):
	if tilt_tween:
		tilt_tween.kill()

	tilt_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tilt_tween.tween_property(mesh, "rotation", target_rot, 0.4)
