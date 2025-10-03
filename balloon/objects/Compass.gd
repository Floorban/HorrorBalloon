@tool
extends Node3D

@export var rotation_speed := 10.0
@onready var pointer: MeshInstance3D = $CompassModel/Pointer
@onready var target: Node3D = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if not target: return
	var direction_to_target = (target.global_transform.origin - pointer.global_transform.origin).normalized()
	var target_angle = atan2(direction_to_target.x, direction_to_target.z)
	var current_angle = deg_to_rad(pointer.rotation_degrees.y - 90)
	var new_angle = lerp_angle(current_angle, target_angle, delta * rotation_speed)
	pointer.rotation_degrees.y = rad_to_deg(new_angle) + 90
