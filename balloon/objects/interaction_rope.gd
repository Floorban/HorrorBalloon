extends InteractionComponent
class_name InteractionRope

var balloon : BalloonController

@export var sensitivity: float = 0.001
@export var max_rotation_deg: float = 360.0
var current_percentage: float = 0.0

func _ready() -> void:
	super._ready()
	balloon = get_tree().get_first_node_in_group("balloon")
	nodes_to_affect.append(balloon)

func _input(event):
	if not is_interacting:
		return

	if event is InputEventMouseMotion:
		current_percentage += event.relative.x * sensitivity
		current_percentage = clamp(current_percentage, -1, 1)

		var target_rot_y = current_percentage * deg_to_rad(max_rotation_deg)
		notify_nodes(-target_rot_y)
