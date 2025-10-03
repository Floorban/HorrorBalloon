@tool
extends InteractionComponent

var player_is_out := false

var hold_to_switch: bool = true
var hold_time: float = 0.0
var hold_duration: float = 0.3

var climb_position: Vector3
var cross_position: Vector3
var is_on_edge: bool = false

func _ready() -> void:
	super._ready()

func _process(_delta):
	if is_on_edge and Input.is_action_just_pressed("forward"):
		cross_over()

func interact() -> void:
	if not hold_to_switch: return
	super.interact()
	if is_interacting:
		hold_time += get_process_delta_time()

		if hold_time >= hold_duration and not is_occupied:
			climb_player()
			is_occupied = true
			is_on_edge = true

func climb_player():
	if not player: return
	climb_position = object_ref.global_transform.origin + Vector3(0, 1.5, 0) 
	player.global_transform.origin = climb_position
	hold_time = 0.0
	player.can_move = false

func cross_over():
	if not player: return
	is_on_edge = false
	cross_position = climb_position + Vector3(0, 0, 2)

func player_has_entered() -> void:
	player_is_out = false

func player_has_exited() -> void:
	player_is_out = true

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
