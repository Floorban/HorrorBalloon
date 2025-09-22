extends InteractionComponent
class_name InteractionRope

@export var sensitivity: float = 0.01   # how fast rope moves with mouse
@export var return_speed: float = 2.0   # how fast it goes back to center when released

var current_percentage: float = 0.0  # -1 (left) .. 1 (right)

func _ready() -> void:
	super._ready()
	nodes_to_affect.append(get_tree().get_first_node_in_group("balloon"))

func _input(event):
	if not is_interacting:
		return

	if event is InputEventMouseMotion:
		current_percentage += event.relative.x * 0.01
		current_percentage = clamp(current_percentage, 0.0, 1.0)
		notify_nodes(current_percentage)
