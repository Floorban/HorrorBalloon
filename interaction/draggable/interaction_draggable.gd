extends InteractionComponent
class_name InteractionDraggable

@export var fuel_amount: float = 50.0
@export var weight: float = 1.0

@export var drag_distance: float = 0.3
@export var drag_step: float = 0.5
@export var max_drag_distance: float = 1.0
@export var min_drag_distance: float = 0.0
@export var drag_smoothness: float = 0.05

func _ready() -> void:
	super._ready()
	weight = object_ref.mass if object_ref else weight
	
	if object_ref and object_ref.has_signal("body_entered"):
		object_ref.connect("body_entered", Callable(self, "_fire_default_collision"))
		object_ref.contact_monitor = true
		object_ref.max_contacts_reported = 1

func _physics_process(_delta: float) -> void:
	if object_ref:
		last_velocity = object_ref.linear_velocity
		if is_interacting:
			_draggable_interact()

func _input(event) -> void:
	if not is_interacting: return

	if event.is_action_pressed("wheel_up"):
		drag_distance = clamp(drag_distance + drag_step, min_drag_distance, max_drag_distance)
	elif event.is_action_pressed("wheel_down"):
		drag_distance = clamp(drag_distance - drag_step, min_drag_distance, max_drag_distance)

func preInteract(hand: Marker3D, target: Node = null) -> void:
	super.preInteract(hand, target)
	player_hand = hand

func interact() -> void:
	super.interact()
	_draggable_interact()

func postInteract() -> void:
	super.postInteract()
	if object_ref:
		object_ref.linear_velocity = Vector3.ZERO

func auxInteract() -> void:
	super.auxInteract()
	_draggable_throw()

func _draggable_interact() -> void:
	if not object_ref or not player_hand:
		return

	var rigid_body_3d: RigidBody3D = object_ref as RigidBody3D
	if rigid_body_3d:
		var target_position: Vector3 = player_hand.global_transform.origin - player_hand.global_transform.basis.z * drag_distance
		var object_distance: Vector3 = target_position - rigid_body_3d.global_transform.origin
		var target_velocity: Vector3 = object_distance * (15.0 / rigid_body_3d.mass)
		rigid_body_3d.linear_velocity = rigid_body_3d.linear_velocity.lerp(target_velocity, drag_smoothness)

func _draggable_throw() -> void:
	if not object_ref or not player_hand:
		return

	var rigid_body_3d: RigidBody3D = object_ref as RigidBody3D
	if rigid_body_3d:
		var throw_direction: Vector3 = -player_hand.global_transform.basis.z.normalized()
		var throw_strength: float = (10.0/rigid_body_3d.mass)
		rigid_body_3d.set_linear_velocity(throw_direction*throw_strength)
		
		can_interact = false
		is_interacting = false
		await get_tree().create_timer(2.0).timeout
		can_interact = true
