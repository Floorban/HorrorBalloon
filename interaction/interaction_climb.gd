@tool
extends InteractionComponent
class_name InteractionClimb

var player_is_out := false

var hold_to_switch: bool = true
var hold_time: float = 0.0
var hold_duration: float = 0.3

@onready var exit_1: Marker3D = $"../exit_1"
@onready var exit_2: Marker3D = $"../exit_2"
@onready var normal_check_ray: RayCast3D = $"../RayCast3D"

func check_player_side(interact_ray: RayCast3D) -> void:
	var player_dir: Vector3 = interact_ray.global_transform.basis.x.normalized()
	var local_dir: Vector3 = normal_check_ray.global_transform.basis.inverse() * player_dir

	if local_dir.z > 0:
		go_to_exit(exit_2)
	else:
		go_to_exit(exit_1)

func interact() -> void:
	if not hold_to_switch: return
	super.interact()
	if is_interacting:
		hold_time += get_process_delta_time()

func go_to_exit(exit_marker: Marker3D) -> void:
	player.global_transform.origin = exit_marker.global_position

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
