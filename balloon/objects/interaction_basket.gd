@tool
extends InteractionComponent
class_name InteractionBasket

var hold_to_switch: bool = true
var hold_time: float = 0.0
var hold_duration: float = 0.3

var player_is_out := true
@onready var exit_1: Marker3D = $"../Exit_1"
@onready var exit_2: Marker3D = $"../Exit_2"
@onready var exit_3: Marker3D = $"../Exit_3"
@onready var exit_4: Marker3D = $"../Exit_4"

func _ready() -> void:
	super._ready()
	can_interact = false

func _input(event):
	if not is_interacting: return

	## Release to switch
	if hold_to_switch:
		if is_occupied and event.is_action_released("primary"):
			hold_edge()
			is_occupied = false
			is_interacting = false
	## Click again to switch
	elif is_occupied and event.is_action_pressed("primary"):
			hold_edge()
			is_occupied = false
	
	if is_occupied and event.is_action_pressed("forward"):
		get_out()

## Click to to switch
func preInteract(_hand: Marker3D, _target: Node = null) -> void:
	super.preInteract(_hand, _target) ## put it before the mode check otherwise can't be detected as is_interacting when hold_to_switch mode
	if player_is_out:
		get_in()
		player_is_out = false
		return

	if hold_to_switch: return

	if not is_occupied:  										   
		hold_edge()
		is_occupied = true

## Hold to switch
func interact() -> void:
	if not hold_to_switch: return
	
	super.interact()
	if is_interacting:
		hold_time += get_process_delta_time()

		if hold_time >= hold_duration and not is_occupied:
			hold_edge()
			is_occupied = true

func hold_edge() -> void:
	if player: player.set_viewing_mode()	
	hold_time = 0.0

func get_closest_exit() -> Marker3D:
	var exits: Array[Marker3D] = [exit_1, exit_2, exit_3, exit_4]
	var closest_exit: Marker3D = exit_1
	var closest_dist: float = INF
	for exit in exits:
		var dist: float = exit.global_position.distance_to(player.global_position) if player else INF
		if dist < closest_dist:
			closest_dist = dist
			closest_exit = exit
	return closest_exit

func get_out() -> void:
	if not player: return

	player.global_transform.origin = get_closest_exit().global_transform.origin
	#player.global_translate(get_closest_exit().global_transform.origin)
	hold_edge()
	is_interacting = false
	is_occupied = false
	player_is_out = true

func get_in() -> void:
	if not player: return

	var center : Vector3 = get_parent().global_transform.origin
	var closest_exit_pos := get_closest_exit().global_transform.origin

	#var enter : Vector3 = center.lerp(closest_exit_pos, 0.5)
	player.global_transform.origin = center.lerp(closest_exit_pos, 0.5)
	
	is_interacting = false
	is_occupied = false

func _get_property_list() -> Array[Dictionary]:
	var ret: Array[Dictionary] = []
	ret.append({
		"name": "_hold_to_switch",
		"type": TYPE_BOOL,
	})
	if hold_to_switch:
		ret.append({
			"name": "_hold_duration",
			"type": TYPE_FLOAT,
		})
	return ret

func _set(prop_name: StringName, val) -> bool:
	var retval := true
	match prop_name:
		"_hold_to_switch":
			hold_to_switch = val
			notify_property_list_changed()
		"_hold_duration":
			hold_duration = val
			notify_property_list_changed()
		_:
			retval = false
	return retval

func _get(prop_name: StringName):
	match prop_name:
		"_hold_to_switch":
			return hold_to_switch
		"_hold_duration":
			return hold_duration
	return null

func _on_player_check_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		can_interact = true

func _on_player_check_body_exited(body: Node3D) -> void:
	if body is PlayerController:
		can_interact = false
		if player: player.interaction_controller._unfocus()
