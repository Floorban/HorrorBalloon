extends InteractionComponent
class_name InteractionHolddable

@export var fuel_amount := 10.0
@export var weight: float = 1.0

func _ready() -> void:
	super._ready()

func preInteract(hand: Marker3D, target: Node = null) -> void:
	super.preInteract(hand, target)
	player_hand = hand
	if not is_occupied: 
		pickup()
		is_occupied = true
	else:
		drop()
		is_occupied = false

func _process(_delta: float) -> void:
	if is_occupied and object_ref:
		object_ref.global_position = player_hand.global_transform.origin
		#object_ref.global_rotation = player_hand.global_transform.basis.get_euler() + Vector3(0, deg_to_rad(90), 0)

func auxInteract() -> void:
	super.auxInteract()

func pickup():
	if object_ref is RigidBody3D:
		object_ref.angular_velocity = Vector3.ZERO
		object_ref.linear_velocity = Vector3.ZERO

	object_ref.global_position = player_hand.global_transform.origin
	#object_ref.global_rotation = player_hand.global_transform.basis.get_euler() + Vector3(0, deg_to_rad(90), 0)
	is_occupied = true

func drop():
	is_occupied = false
	if object_ref:
		var ground_pos = _get_ground()
		object_ref.global_position = ground_pos

func _get_ground() -> Vector3:
	if not object_ref or not (object_ref is Node3D):
		return Vector3.ZERO

	var space_state = object_ref.get_world_3d().direct_space_state
	
	var start = object_ref.global_position
	var end = start - Vector3.UP * 10.0
	
	var query = PhysicsRayQueryParameters3D.new()
	query.from = start
	query.to = end
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.exclude = [object_ref]
	
	var result = space_state.intersect_ray(query)
	
	if result.has("position"):
		return result.position
	else:
		return object_ref.global_position
