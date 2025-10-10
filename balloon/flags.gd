extends Node3D

@onready var follow_owner: BalloonController = get_tree().get_first_node_in_group("balloon")
var my_flags: Array = []
@export var attached_rope: VerletRope

func _ready() -> void:
	if attached_rope == null:
		return
	_get_child_flags()
	_assign_flags_to_verlets(attached_rope)

func _physics_process(delta: float) -> void:
	if follow_owner == null:
		return

	var move_dir = follow_owner.horizontal_dir
	if move_dir.length() > 0.01:
		var target_yaw = atan2(-move_dir.x, -move_dir.y)

		for flag in my_flags:
			var current_rot = flag.rotation
			var new_yaw = lerp_angle(current_rot.y, target_yaw + 90, delta * 5.0)
			flag.rotation = Vector3(deg_to_rad(-90.0), new_yaw, 0.0)

func _get_child_flags() -> void:
	for flag in get_children():
		my_flags.append(flag)

func _assign_flags_to_verlets(rope: VerletRope) -> void:
	var dist = int(rope.simulation_particles / 5.0)
	for i in my_flags.size():
		rope.attach_object_to_particle(dist * (i + 1), my_flags[i])
