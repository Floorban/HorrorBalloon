@tool
extends Node3D

@export var rotation_speed := 10.0
@onready var pointer: MeshInstance3D = $StaticBody3D/CompassModel/Pointer
@onready var target: Node3D = get_tree().get_first_node_in_group("lighthouse")

func _process(delta: float) -> void:
	if not target:
		return

	var local_target_pos = to_local(target.global_position)
	local_target_pos.y = 0.0
	var target_angle = atan2(local_target_pos.x, local_target_pos.z)
	target_angle += deg_to_rad(90)
	var current_angle = pointer.rotation.y
	var new_angle = lerp_angle(current_angle, target_angle, delta * rotation_speed)
	pointer.rotation.y = new_angle
