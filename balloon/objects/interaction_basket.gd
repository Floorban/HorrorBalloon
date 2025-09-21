@tool
extends InteractionComponent
class_name InteractionBasket

var player: PlayerController
var is_occupied := false

func _ready() -> void:
	super._ready()
	player = get_tree().get_first_node_in_group("player") as PlayerController

func _input(event):
	if is_occupied and event.is_action_pressed("primary"): 
		hold_edge()
		is_occupied = false

func postInteract() -> void:
	super.postInteract()
	if not is_occupied: 
		hold_edge()
		is_occupied = true

func hold_edge() -> void:
	if player: player.set_viewing_mode()	