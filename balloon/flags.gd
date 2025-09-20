extends Node3D

var my_flags : Array[Node3D]
@export var attached_rope : VerletRope

func _ready() -> void:
	if attached_rope == null: return
	_get_child_flags()
	_assign_flags_to_verlets(attached_rope)

func _get_child_flags() -> void:
	for flag in get_children():
		my_flags.append(flag)

func _assign_flags_to_verlets(rope: VerletRope) -> void:
	var dist = int(rope.simulation_particles / 5.0)
	for i in my_flags.size():
		print(i)
		rope.attach_object_to_particle(dist*(i+1), my_flags[i])
