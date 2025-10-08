extends RigidBody3D
class_name BalloonController

signal has_landed

@onready var player: PlayerController = get_tree().get_first_node_in_group("player")
@onready var balloon_body: Node3D = $Body
@onready var oven: Node = %Oven

@onready var obj_in_balloon_area: Area3D = %ObjInBalloonArea
# var _is_reparenting := false
@onready var ground_checks := [%GroundCheck_1, %GroundCheck_2, %GroundCheck_3, %GroundCheck_4, %GroundCheck_5]
var is_grounded := false
var ground_check_enabled := true
var ground_disable_timer := 0.0

# weight / objects in balloon
var objs_in_balloon: Dictionary = {}
var total_weight: float = 0.0
var player_weight: float = 5.0

# input component
@export var input_component: Array[BalloonInput]

# vertical
const GRAVITY := 3.0
@export var vertical_base_force: float = 100.0
var vertical_force: float = 0.0
var is_just_land : = false

# horizontal
@export var horizontal_base_force: float = 100.0
var move_threshold := 0.1
var horizontal_dir: Vector2 = Vector2.ZERO

# tilt
@export var max_tilt_angle := 10.0
var tilt_tween: Tween = null
var tilt_damping := 0.5

## Sound Settings
@export var SFX_Engine: String
@export var SFX_Land: String

func _ready() -> void:
	objs_in_balloon.clear()
	if obj_in_balloon_area:
		obj_in_balloon_area.body_entered.connect(_on_body_entered)
		obj_in_balloon_area.body_exited.connect(_on_body_exited)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var lv = state.linear_velocity
	lv.x = clamp(lv.x, -1.5, 1.5)
	lv.z = clamp(lv.z, -1.5, 1.5)
	lv.y = clamp(lv.y, -4, 2)
	state.linear_velocity = lv

func _physics_process(delta: float) -> void:
	if not ground_check_enabled:
		ground_disable_timer -= delta
		if ground_disable_timer <= 0.0:
			ground_check_enabled = true

	var touching_ground := false
	if ground_check_enabled:
		touching_ground = _check_ground_contacts()

	if not is_grounded:
		apply_central_force(Vector3.DOWN * GRAVITY)
	
	if not is_grounded and touching_ground and linear_velocity.y <= 0.1:
		_on_land()
	if is_grounded and oven.get_fuel_percentage() > 0.1:
		_on_takeoff()
	if not ground_check_enabled and oven.get_fuel_percentage() > 0:
		player.trauma = 0.5

	get_balloon_input()
	update_balloon_movement()

func get_balloon_input() -> Vector3:
	if input_component.size() == 0:
		return Vector3.ZERO

	var vertical_input: float = 0.0
	var horizontal_input: Vector2 = Vector2.ZERO

	for i in input_component.size():
		var ic = input_component[i]
		if not ic:
			continue
		vertical_input += ic.get_vertical_input()
		horizontal_input += ic.get_horizontal_input()

	vertical_input = clamp(vertical_input, -1.0, 1.0)
	horizontal_input = horizontal_input.normalized()
	return Vector3(horizontal_input.x, vertical_input, horizontal_input.y)

func update_balloon_movement() -> void:
	_apply_vertical_force()
	_apply_horizontal_force()

func _apply_vertical_force() -> void:
	if is_grounded:
		return

	var fuel_mult : float = oven.get_fuel_percentage() if oven else 0.0
	vertical_force = vertical_base_force * fuel_mult * get_balloon_input().y #- (GRAVITY * total_weight * 0.05)
	apply_central_force(Vector3.UP * vertical_force)

func _apply_horizontal_force() -> void:
	# Stop horizontal motion if grounded
	if is_grounded:
		_tilt_to(Vector3.FORWARD * 0.1, tilt_damping * 2.0)
		horizontal_dir = Vector2.ZERO
		return

	# var final_tilt: Vector3 = _compute_weighted_tilt()
	# _tilt_to(Vector3(final_tilt.x, 0.0, -final_tilt.z), tilt_damping)
	# var local_dir = Vector3(final_tilt.z, 0.0, final_tilt.x)
	# horizontal_dir = (global_transform.basis * local_dir).normalized()
	# if horizontal_dir.length() > move_threshold:
	horizontal_dir = Vector2(get_balloon_input().x, get_balloon_input().z)
	var target_force : Vector3 = horizontal_base_force * horizontal_dir.length() * Vector3(horizontal_dir.x, 0.0, horizontal_dir.y).normalized()
	apply_central_force(target_force)

	# if player and player.has_method("apply_player_camera_sway"):
	# 	player.apply_player_camera_sway(final_tilt)

func _on_land() -> void:
	Audio.play(SFX_Land, global_transform)
	is_grounded = true
	linear_velocity = Vector3.ZERO
	sleeping = true
	player.trauma = 0.8
	has_landed.emit()
	print("Balloon landed")

func _on_takeoff() -> void:
	Audio.play(SFX_Engine, global_transform)
	is_grounded = false
	sleeping = false
	linear_velocity.y = vertical_base_force * 0.1
	player.trauma = 0.5
	print("Balloon taking off")
	ground_check_enabled = false
	ground_disable_timer = 1.0

func _check_ground_contacts() -> bool:
	for i in ground_checks.size():
		var gc = ground_checks[i]
		if not gc:
			continue
		gc.force_raycast_update()
		if gc.is_colliding():
			var col = gc.get_collider()
			if col and col != self:
				return true
	return false

func _get_all_weights() -> float:
	var sum: float = 0.0
	for val in objs_in_balloon.values():
		sum += float(val)
	return sum

func _compute_weighted_tilt() -> Vector3:
	if objs_in_balloon.is_empty(): return Vector3.ZERO

	var total_influence := Vector3.ZERO
	var weight_sum := 0.0

	for obj in objs_in_balloon.keys():
		if not obj: continue

		var weight := float(objs_in_balloon[obj])
		var rel_pos_local := to_local(obj.global_transform.origin)
		if obj is InteractionComponent: rel_pos_local = obj.object_ref.global_position - global_position

		var x_dir : float = clamp(rel_pos_local.x, -1.0, 1.0)
		var z_dir : float = clamp(rel_pos_local.z, -1.0, 1.0)

		total_influence += Vector3(z_dir * weight, 0.0, x_dir * weight)
		weight_sum += weight

	if weight_sum > 0.0:
		var avg := total_influence / weight_sum
		var target_x_rot := avg.x * max_tilt_angle
		var target_z_rot := avg.z * max_tilt_angle
		return Vector3(deg_to_rad(target_x_rot), 0.0, deg_to_rad(target_z_rot))

	return Vector3.ZERO

func _tilt_to(target_rot: Vector3, damping: float) -> void:
	if tilt_tween: tilt_tween.kill()
	tilt_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tilt_tween.tween_property(balloon_body, "rotation", target_rot, damping)

# Called externally to rotate the balloon with rope
func execute(percentage: float) -> void:
	if tilt_tween: tilt_tween.kill()
	tilt_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tilt_tween.tween_property(self, "rotation:y", percentage, 10.0)

func _on_body_entered(body: Node3D) -> void:
	# if _is_reparenting:
	# 	return
	if body == player:
		objs_in_balloon[body] = player_weight
		#_is_reparenting = true
		#call_deferred("_deferred_attach", player)
# if body.is_in_group("interactable"):
# 	var obj = body.get_node_or_null("InteractionComponent")
# 	if obj is InteractionHolddable:
# 		objs_in_balloon[body] = obj.weight
			# _is_reparenting = true
			# call_deferred("_deferred_attach", body)
	total_weight = _get_all_weights()

func _on_body_exited(body: Node3D) -> void:
	# if _is_reparenting or not body:
	# 	return
	# if body == player or body.is_in_group("interactable"):
		# _is_reparenting = true
		# call_deferred("_deferred_deattach", body)
	if objs_in_balloon.has(body):
		objs_in_balloon.erase(body)
	total_weight = _get_all_weights()

# func _deferred_attach(body: Node3D) -> void:
# 	_is_reparenting = true
# 	if not body:
# 		_is_reparenting = false
# 		return

# 	if body.get_parent() == self:
# 		_is_reparenting = false
# 		return

# 	var old_transform: Transform3D = body.global_transform

# 	if obj_in_balloon_area:
# 		obj_in_balloon_area.monitoring = false

# 	var parent = body.get_parent()
# 	if parent:
# 		parent.remove_child(body)
# 	balloon_body.add_child(body)

# 	body.global_transform = old_transform

# 	if obj_in_balloon_area:
# 		obj_in_balloon_area.monitoring = true

# 	_is_reparenting = false

# func _deferred_deattach(body: Node3D) -> void:
# 	_is_reparenting = true
# 	if not body:
# 		_is_reparenting = false
# 		return

# 	var current_scene: Node = get_tree().current_scene
# 	if body.get_parent() == current_scene:
# 		_is_reparenting = false
# 		return

# 	var old_transform: Transform3D = body.global_transform

# 	if obj_in_balloon_area:
# 		obj_in_balloon_area.monitoring = false

# 	var parent = body.get_parent()
# 	if parent:
# 		parent.remove_child(body)
# 	current_scene.add_child(body)

# 	body.global_transform = old_transform

# 	if obj_in_balloon_area:
# 		obj_in_balloon_area.monitoring = true

# 	_is_reparenting = false