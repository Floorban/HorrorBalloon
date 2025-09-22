@tool
extends InteractionComponent
class_name InteractionHolddable

@export var fuel_amount := 10.0

var pickup_tween: Tween
var is_occupied := false

func _ready() -> void:
	super._ready()

func preInteract(hand: Marker3D, target: Node = null) -> void:
	super.preInteract(hand, target)
	player_hand = hand
	if not is_occupied: 
		pickup()
		is_occupied = true

func interact() -> void:
	if is_occupied and object_ref:
		object_ref.global_position = player_hand.global_transform.origin
		object_ref.global_rotation = player_hand.global_transform.basis.get_euler()

func postInteract() -> void:
	super.postInteract()
	release()
	is_occupied = false

func pickup():
	if object_ref is RigidBody3D:
		object_ref.angular_velocity = Vector3.ZERO
		object_ref.linear_velocity = Vector3.ZERO
		object_ref.freeze = true
		object_ref.set_collision_layer_value(1, false)
		object_ref.set_collision_mask_value(1, false)

	object_ref.reparent(player_hand.get_parent().get_parent().get_parent())

	await get_tree().create_timer(0.1).timeout

	pickup_tween = create_tween()
	pickup_tween.tween_property(
		object_ref, "global_position", player_hand.global_position, 0.1
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	pickup_tween.tween_property(
		object_ref, "global_rotation", player_hand.global_rotation, 0.1
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	pickup_tween.play()

	is_occupied = true

func release():
	if pickup_tween and pickup_tween.is_valid():
		pickup_tween.kill()
		pickup_tween = null

	object_ref.reparent(get_tree().get_first_node_in_group("balloon"))
	is_occupied = false
	object_ref.freeze = false
	object_ref.set_collision_layer_value(1, true)
	object_ref.set_collision_mask_value(1, true)
