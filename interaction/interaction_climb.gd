@tool
extends InteractionComponent
class_name InteractionClimb

var hold_to_switch: bool = true
var hold_time: float = 0.0
var hold_duration: float = 0.3
@export var viewing_offet : Vector3 = Vector3(0, 5.0, -0.5)
@export var viewing_zoom : float = 0.8

@onready var interact_area: Area3D = $"../InteractArea"
var target_pos := Vector3.ZERO
@onready var exit_1: Marker3D = $"../Exit1"
@onready var exit_2: Marker3D = $"../Exit2"
@onready var normal_check_ray: RayCast3D = $"../NormalCheckRay"

func check_player_side(interact_ray: RayCast3D) -> void:
	var player_dir: Vector3 = interact_ray.global_transform.basis.x.normalized()
	var local_dir: Vector3 = normal_check_ray.global_transform.basis.inverse() * player_dir
	if local_dir.z > 0:
		target_pos = exit_2.global_position
	else:
		target_pos = exit_1.global_position

func _ready() -> void:
	super._ready()
	can_interact = false
	if interact_area:
		interact_area.body_entered.connect(_on_player_entered)
		interact_area.body_exited.connect(_on_player_exited)

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
	
	#if is_occupied and event.is_action_pressed("climb"):
		#go_to_exit()

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

func go_to_exit() -> void:
	if not player: return
	player.set_viewing_mode()
	player.global_transform.origin = target_pos
	is_interacting = false
	is_occupied = false

func hold_edge() -> void:
	if not player: return
	player.set_viewing_mode(viewing_offet, viewing_zoom)
	hold_time = 0.0

func _on_player_entered(body: Node3D) -> void:
	if body is PlayerController:
		can_interact = true

func _on_player_exited(body: Node3D) -> void:
	if body is PlayerController:
		can_interact = false
		body.interaction_controller._unfocus()

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
