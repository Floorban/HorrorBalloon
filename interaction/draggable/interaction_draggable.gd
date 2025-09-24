extends InteractionComponent
class_name InteractionDraggable

func _ready() -> void:
	super._ready()

	if object_ref.has_signal("body_entered"):
		object_ref.connect("body_entered", Callable(self, "_fire_default_collision"))
		object_ref.contact_monitor = true
		object_ref.max_contacts_reported = 1

func _physics_process(_delta: float) -> void:
	if object_ref:
		last_velocity = object_ref.linear_velocity

func preInteract(hand: Marker3D, target: Node = null) -> void:
	super.preInteract(hand, target)
	player_hand = hand

func interact() -> void:
	super.interact()
	_draggable_interact()

func auxInteract() -> void:
	super.auxInteract()
	_draggable_throw()

## Default Interaction with objects that can be dragged around
func _draggable_interact() -> void:
	var object_current_position: Vector3 = object_ref.global_transform.origin
	var player_hand_position: Vector3 = player_hand.global_transform.origin
	var object_distance: Vector3 = player_hand_position-object_current_position
	
	var rigid_body_3d: RigidBody3D = object_ref as RigidBody3D
	if rigid_body_3d:
		rigid_body_3d.set_linear_velocity((object_distance)*(2/rigid_body_3d.mass))

## Alternate Interaction with objects that can be dragged around
func _draggable_throw() -> void:
	# var object_current_position: Vector3 = object_ref.global_transform.origin
	# var player_hand_position: Vector3 = player_hand.global_transform.origin
	# var object_distance: Vector3 = player_hand_position-object_current_position
	
	var rigid_body_3d: RigidBody3D = object_ref as RigidBody3D
	if rigid_body_3d:
		var throw_direction: Vector3 = -player_hand.global_transform.basis.z.normalized()
		var throw_strength: float = (10.0/rigid_body_3d.mass)
		rigid_body_3d.set_linear_velocity(throw_direction*throw_strength)
		
		can_interact = false
		await get_tree().create_timer(2.0).timeout
		can_interact = true
