extends InteractionComponent
class_name InteractionAirRelease

var original_pos: Vector3

func _ready() -> void:
	super._ready()
	original_pos = object_ref.position

func preInteract(_hand: Marker3D, _target: Node = null) -> void:
	super.preInteract(_hand, _target)
	player_hand = _hand

func interact() -> void:
	super.interact()
	if object_ref is RigidBody3D:
		var target_velocity: Vector3 = original_pos + Vector3.DOWN * 2.0
		object_ref.set_linear_velocity(object_ref.linear_velocity.lerp(target_velocity, 0.5))

func postInteract() -> void:
	super.postInteract()
	is_interacting = false
	object_ref.position = lerp(object_ref.position, original_pos, 0.5)
