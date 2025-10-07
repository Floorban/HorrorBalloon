extends InteractionComponent
#class_name InteractionInspect

var is_zoomed_in := false
@export var zoom_position_offset := Vector3(-0.08, 0.18, -0.15)
@export var zoom_rotation_offset := Vector3(10, 15, 0) 
@export var zoom_speed := 0.1
var tween: Tween

func _ready() -> void:
	super._ready()

func preInteract(hand: Marker3D, target: Node = null) -> void:
	super.preInteract(hand, target)

func _input(event: InputEvent) -> void:
	if not is_occupied: return
	if event.is_action_pressed("primary"):
		zoom_in()
	elif event.is_action_released("primary"):
		zoom_out()

func zoom_in() -> void:
	if not object_ref or is_zoomed_in:
		return
	is_zoomed_in = true
	var target_pos = player_hand.to_global(zoom_position_offset)
	var target_rot = player_hand.global_rotation + Vector3(
		deg_to_rad(zoom_rotation_offset.x),
		deg_to_rad(zoom_rotation_offset.y),
		deg_to_rad(zoom_rotation_offset.z))
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(object_ref, "global_position", target_pos, zoom_speed) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(object_ref, "global_rotation", target_rot, zoom_speed) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func(): is_zoomed_in = true)
	player.set_viewing_mode(Vector3.ZERO, 0.7)

func zoom_out() -> void:
	if not object_ref or not is_zoomed_in:
		return

	is_zoomed_in = false
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_callback(func(): object_ref.global_position = player_hand.global_position)
	tween.tween_callback(func(): object_ref.global_rotation = player_hand.global_rotation)
	tween.tween_callback(func(): object_ref.global_rotation = player_hand.global_rotation)
	tween.tween_interval(zoom_speed)
	player.set_viewing_mode()
