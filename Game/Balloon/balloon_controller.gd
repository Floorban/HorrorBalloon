extends RigidBody3D
class_name BalloonController

@export var lift_force := 10.0
@export var down_force := 1.0
@export var horizontal_force := 0.1

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
	# move forward/back
	if abs(rel_pos.x) > 0.3:
		apply_central_force(Vector3(rel_pos.x, 0, 0).normalized() * horizontal_force)
	# move left/right
	if abs(rel_pos.z) > 0.25:
		apply_central_force(Vector3(0, 0, rel_pos.z).normalized() * horizontal_force)
