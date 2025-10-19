extends InteractionComponent
class_name InteractionDiggable

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
		object_ref.global_rotate(Vector3.UP, rot_y)
		object_ref.global_rotate(Vector3.RIGHT, rot_x)
	
	if not rotating:
		if event.is_action_pressed("wheel_up"):
			drag_distance = clamp(drag_distance + drag_step, min_drag_distance, max_drag_distance)
		elif event.is_action_pressed("wheel_down"):
			drag_distance = clamp(drag_distance - drag_step, min_drag_distance, max_drag_distance)

func preInteract(hand: Marker3D, target: Node = null) -> void:
	super.preInteract(hand, target)
	player_hand = hand
	player.hold_back_speed = -object_ref.mass / 5.0
	#drag_distance = -0.3
	drag_distance = (player_hand.global_position - object_ref.global_position).length()

func interact() -> void:
	super.interact()
	_diggable_interact()

func postInteract() -> void:
	super.postInteract()
	rotating = false
	player.hold_back_speed = 0.0

func _diggable_interact():
	pass