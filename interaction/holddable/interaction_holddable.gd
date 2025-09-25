extends InteractionComponent
class_name InteractionHolddable

@export var fuel_amount := 10.0

func _ready() -> void:
	super._ready()

func preInteract(hand: Marker3D, target: Node = null) -> void:
	super.preInteract(hand, target)
	player_hand = hand
	if not is_occupied: 
		#pickup()
		is_occupied = true

func _input(event: InputEvent) -> void:
	if is_occupied and event.is_action_pressed("secondary"):
		drop()

func _physics_process(_delta: float) -> void:
	if is_occupied and object_ref:
		object_ref.global_position = player_hand.global_transform.origin
		object_ref.global_rotation = player_hand.global_transform.basis.get_euler() + Vector3(0, deg_to_rad(90), 0)

func auxInteract() -> void:
	super.auxInteract()
	_holddable_throw()

#func postInteract() -> void:
	#super.postInteract()
	#drop()
	#is_occupied = false

func pickup():
	if object_ref is RigidBody3D:
		object_ref.angular_velocity = Vector3.ZERO
		object_ref.linear_velocity = Vector3.ZERO
		#object_ref.set_collision_layer_value(1, false)

	object_ref.reparent(player_hand.get_parent().get_parent().get_parent())
	object_ref.global_position = player_hand.global_transform.origin
	object_ref.global_rotation = player_hand.global_transform.basis.get_euler() + Vector3(0, deg_to_rad(90), 0)
	is_occupied = true

func drop():
	#var current_transform = object_ref.global_transform
	#object_ref.global_transform = current_transform

	is_occupied = false
	object_ref.angular_velocity = Vector3.ZERO
	object_ref.linear_velocity = Vector3.ZERO
	#object_ref.set_collision_layer_value(1, true)

func _holddable_throw() -> void:
	drop()
	var rigid_body_3d: RigidBody3D = object_ref as RigidBody3D
	if rigid_body_3d:
		var throw_direction: Vector3 = -player_hand.global_transform.basis.z.normalized()
		var throw_strength: float = (3.0/rigid_body_3d.mass)
		rigid_body_3d.set_linear_velocity(throw_direction*throw_strength)
		
		can_interact = false
		await get_tree().create_timer(2.0).timeout
		can_interact = true
