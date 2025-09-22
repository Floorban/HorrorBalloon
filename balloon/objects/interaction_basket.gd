@tool
extends InteractionComponent
class_name InteractionBasket

var is_occupied := false
var hold_to_switch: bool = true
var hold_time: float = 0.0
var hold_duration: float = 0.3

func _ready() -> void:
	super._ready()

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

## Click to to switch
func preInteract(_hand: Marker3D, _target: Node = null) -> void:
	super.preInteract(_hand, _target) ## put it before the mode check otherwise can't be detected as is_interacting when hold_to_switch mode
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
