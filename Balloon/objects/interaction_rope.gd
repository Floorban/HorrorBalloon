extends InteractionComponent
class_name InteractionRope

var balloon : BalloonController

@export var sensitivity: float = 0.01
@export var max_rotation_deg: float = 360.0
var player_start_rotation: Vector3
var balloon_start_rotation: Vector3
var balloon_end_rotation: Vector3

var current_percentage: float = 0.0

func _ready() -> void:
	super._ready()
	balloon = get_tree().get_first_node_in_group("balloon")
	nodes_to_affect.append(balloon)
	camera = player.player_camera

func preInteract(hand: Marker3D, target: Node = null) -> void:
	super.preInteract(hand, target)
	player_start_rotation = player.global_rotation
	# lock_camera = true
	player.set_viewing_mode()
	balloon_start_rotation = balloon.global_rotation

func _input(event):
	if not is_interacting:
		return

	if event is InputEventMouseMotion:
		current_percentage += event.relative.x * sensitivity
		current_percentage = clamp(current_percentage, -.5, .5)

		var target_rot_y = current_percentage * deg_to_rad(max_rotation_deg)
		notify_nodes(-target_rot_y)
	else:
		lock_camera = false
		player.set_viewing_mode()

func postInteract() -> void:
	super.postInteract()

	balloon_end_rotation = balloon.global_rotation
	var end_rot : Vector3 = player_start_rotation
	var diff_rot : Vector3 = balloon_end_rotation - balloon_start_rotation
	end_rot = player_start_rotation + diff_rot
	player.reset_player_rotation(diff_rot)