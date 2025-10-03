extends InteractionComponent
class_name InteractionDraggable

@export var fuel_amount: float = 50.0
@export var weight: float = 1.0

@export var drag_distance: float
@export var drag_step: float = 0.2
@export var max_drag_distance: float = 0.6
@export var min_drag_distance: float = -0.3
@export var drag_smoothness: float = 1.0

var rotating: bool = false
var rotation_speed: float = 0.001

func _ready() -> void:
	super._ready()
	weight = object_ref.mass if object_ref else weight
	if object_ref and object_ref.has_signal("body_entered"):
		object_ref.connect("body_entered", Callable(self, "_fire_default_collision"))
		object_ref.contact_monitor = true
		object_ref.max_contacts_reported = 1

func _input(event) -> void:
	if not is_interacting: return

	if event.is_action_pressed("wheel_up"):
		drag_distance = clamp(drag_distance + drag_step, min_drag_distance, max_drag_distance)
	elif event.is_action_pressed("wheel_down"):
		drag_distance = clamp(drag_distance - drag_step, min_drag_distance, max_drag_distance)
	
	if event.is_action_pressed("rotate_object"):
		rotating = true
		lock_camera = true
	elif event.is_action_released("rotate_object"):
		rotating = false
		lock_camera = false

	if rotating and event is InputEventMouseMotion:
		var mouse_motion : Vector2 = event.relative
		var rot_x := mouse_motion.y * rotation_speed
		var rot_y := mouse_motion.x * rotation_speed
		object_ref.rotate(Vector3.UP, rot_y)
		object_ref.rotate(Vector3.RIGHT, rot_x)

func preInteract(hand: Marker3D, target: Node = null) -> void:
	super.preInteract(hand, target)
	player_hand = hand
	player.hold_back_speed = -object_ref.mass / 5.0
	drag_distance = (player_hand.global_position - object_ref.global_position).length()
	object_ref.set_collision_layer_value(1, false)
	object_ref.axis_lock_angular_x = true
	object_ref.axis_lock_angular_y = true
	object_ref.axis_lock_angular_z = true

func interact() -> void:
	super.interact()
	_draggable_interact()

func postInteract() -> void:
	super.postInteract()
	rotating = false
	player.hold_back_speed = 0.0
	object_ref.set_collision_layer_value(1, true)
	object_ref.axis_lock_angular_x = false
	object_ref.axis_lock_angular_y = false
	object_ref.axis_lock_angular_z = false

func auxInteract() -> void:
	super.auxInteract()
	_draggable_throw()

func _draggable_interact() -> void:
	if not object_ref or not player_hand:
		return
	
	if rotating:
		object_ref.global_position = (last_velocity)
	
	if object_ref is RigidBody3D:
		var target_position: Vector3 = player_hand.global_transform.origin - player_hand.global_transform.basis.z * drag_distance
		var object_distance: Vector3 = target_position - object_ref.global_transform.origin
		var target_velocity: Vector3 = object_distance * (30.0 / object_ref.mass)
		object_ref.set_linear_velocity(object_ref.linear_velocity.lerp(target_velocity, drag_smoothness))
		last_velocity = object_ref.global_transform.origin

func _draggable_throw() -> void:
	if not object_ref or not player_hand:
		return

	if object_ref is RigidBody3D:
		var throw_direction: Vector3 = -player_hand.global_transform.basis.z.normalized()
		var throw_strength: float = (10.0/object_ref.mass)
		object_ref.set_linear_velocity(throw_direction*throw_strength)
		
		can_interact = false
		is_interacting = false
		player.hold_back_speed = 0.0
		object_ref.set_collision_layer_value(1, true)
		rotating = false
		object_ref.axis_lock_angular_x = false
		object_ref.axis_lock_angular_y = false
		object_ref.axis_lock_angular_z = false

		await get_tree().create_timer(1.0).timeout
		can_interact = true
