extends RigidBody3D
class_name BalloonController

@onready var player: PlayerController = get_tree().get_first_node_in_group("player")
@onready var balloon_body: Node3D = $Body

##--- sound settings ---
@export var SFX_Engine: String
@export var SFX_Land: String

func _ready() -> void:
	input_init()
	objs_in_balloon.clear()
	if obj_in_balloon_area:
		obj_in_balloon_area.body_entered.connect(_on_body_entered)
		obj_in_balloon_area.body_exited.connect(_on_body_exited)
	refill(max_fuel)

func _physics_process(delta: float) -> void:
	_check_ground_cd_timer(delta) # -> updates ground_check_enabled
	var touching_ground := false
	if ground_check_enabled:
		touching_ground = _check_ground_contacts()
	get_balloon_input()
	update_balloon_states(touching_ground)
	update_balloon_movement()

##--- balloon control input component ---
@export var input_component: Array[BalloonInput]

##--- vector4's 'x,y,z' for movement (vector3), 'w' for rotation parameter
func input_init() -> void:
	if input_component.size() <= 0: return
	for input in input_component:
		input.balloon = self

func get_balloon_input() -> Vector4:
	if input_component.size() == 0:
		return Vector4.ZERO

	var vertical_input: float = 0.0
	var horizontal_input: Vector2 = Vector2.ZERO
	var rotation_input: float = 0.0

	for i in input_component.size():
		var ic = input_component[i]
		if not ic:
			continue
		vertical_input += ic.get_vertical_input()
		horizontal_input += ic.get_horizontal_input()
		rotation_input += ic.get_rotation_input()

	vertical_input = clamp(vertical_input, -1.0, 1.0)
	horizontal_input = horizontal_input.normalized()
	#rotation_input = clamp(rotation_input, -1.0, 1.0)
	return Vector4(horizontal_input.x, vertical_input, horizontal_input.y, rotation_input)

##--- handle fuel ---
var max_fuel = 100.0
var current_fuel = 0.0
var burning_rate = 0.5

func get_balloon_fuel() -> bool:
	return true if current_fuel > 0 else false

func consume_fuel(amount: float) -> void:
	current_fuel = max(current_fuel - amount * burning_rate, 0.0)

func refill(amount : float) -> void:
	current_fuel = min(current_fuel + amount, max_fuel)

##--- balloon movement and rotation ---
func update_balloon_movement() -> void:
	_apply_vertical_force()
	_apply_horizontal_force()
	_apply_rotation()

##--- vertical ---
const GRAVITY := 10.0

@export var vertical_base_force: float = 200.0
var vertical_force: float = 0.0

func _apply_vertical_force() -> void:
	if is_grounded:
		return

	var fuel_mult : float = 1.0 if get_balloon_fuel() else 0.0
	vertical_force = vertical_base_force * fuel_mult * get_balloon_input().y - (GRAVITY * total_weight * 0.05)
	apply_central_force(Vector3.UP * vertical_force)

##--- horizontal ---
@export var weight_based_movement := false
@export var horizontal_base_force: float = 200.0
var horizontal_force: Vector2 = Vector2.ZERO
var move_threshold := 0.1
var horizontal_dir: Vector2 = Vector2.ZERO

func _apply_horizontal_force() -> void:
	# Stop horizontal motion if grounded
	if is_grounded:
		_tilt_to(Vector3.ZERO, tilt_damping * 2.0)
		horizontal_dir = Vector2.ZERO
		return

	var final_tilt: Vector3 = _compute_weighted_tilt()
	_tilt_to(Vector3(final_tilt.x, 0.0, -final_tilt.z), tilt_damping)

	if weight_based_movement:
		var local_dir = Vector3(final_tilt.z, 0.0, final_tilt.x)
		horizontal_dir = Vector2(
			Vector3(global_transform.basis * local_dir).x,
			Vector3(global_transform.basis * local_dir).z).normalized()
	else:
		horizontal_dir = Vector2(get_balloon_input().x, get_balloon_input().z)

	if horizontal_dir.length() > move_threshold:
		horizontal_force = horizontal_base_force * horizontal_dir
	else:
		horizontal_force = Vector2.ZERO
	var h_force : Vector3 = Vector3(horizontal_force.x,0.0,horizontal_force.y)
	apply_central_force(h_force)

	#if player and player.has_method("apply_player_camera_sway"):
		#player.apply_player_camera_sway(final_tilt)

##--- rotate the transform (not using torque force) ---
@export var torque_base_force: float = 0.01
var rotation_dir: float = 0.0

func _apply_rotation() -> void:
	if is_grounded:
		rotation_dir = 0.0
		return
	rotation_dir = get_balloon_input().w
	global_rotate(Vector3.UP, rotation_dir * torque_base_force)

##--- balloon max (linear and angular) speed based on rigidbody, since movement is using add force ---
@export var max_speed_h := 1
@export var max_speed_v := 1
@export var max_speed_r := 1

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var lv = state.linear_velocity
	lv.x = clamp(lv.x, -max_speed_h, max_speed_h)
	lv.z = clamp(lv.z, -max_speed_h, max_speed_h)
	lv.y = clamp(lv.y, -max_speed_v*2, max_speed_v)
	state.linear_velocity = lv
	
	var av = state.angular_velocity
	av.x = clamp(av.x, -max_speed_r, max_speed_r)
	av.y = clamp(av.y, -max_speed_r, max_speed_r)
	av.z = clamp(av.z, -max_speed_r, max_speed_r)
	state.angular_velocity = av

##--- taking off and landing with rays detection ---
signal has_landed
var is_just_land : = false

@onready var ground_checks := [%GroundCheck_1, %GroundCheck_2, %GroundCheck_3, %GroundCheck_4, %GroundCheck_5]
var is_grounded := false
var ground_check_enabled := true
var ground_disable_timer := 0.0

##--- manage transition
func update_balloon_states(touching_ground : bool) -> void:
	if not is_grounded and touching_ground: # and linear_velocity.y <= 0.1
		_on_land()
	if is_grounded and get_balloon_input().y > 0.5:
		_on_takeoff()
	if not ground_check_enabled and get_balloon_input().y > 0.0:
		#taking off feedback here
		pass

func _on_land() -> void:
	#Audio.play(SFX_Land, global_transform)
	is_grounded = true
	linear_velocity = Vector3.ZERO
	sleeping = true
	player.trauma = 0.3
	has_landed.emit()
	print("Balloon landed")

func _on_takeoff() -> void:
	#Audio.play(SFX_Engine, global_transform)
	is_grounded = false
	sleeping = false
	linear_velocity.y = vertical_base_force * 0.01
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

func _check_ground_cd_timer(delta: float) -> void:
	if not ground_check_enabled:
		ground_disable_timer -= delta
		if ground_disable_timer <= 0.0:
			ground_check_enabled = true

##--- obj weight ---
@onready var obj_in_balloon_area: Area3D = %ObjInBalloonArea
# var _is_reparenting := false
var objs_in_balloon: Dictionary = {}
var total_weight: float = 0.0
var player_weight: float = 5.0

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

##--- tilting visual feedback based on weight ---
@export var max_tilt_angle := 10.0
var tilt_tween: Tween = null
var tilt_damping := 0.5

func _tilt_to(target_rot: Vector3, damping: float) -> void:
	if tilt_tween: tilt_tween.kill()
	tilt_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tilt_tween.tween_property(balloon_body, "rotation", target_rot, damping)

## called externally to control the balloon (only rotation now)
func execute(percentage: float, _primary: bool) -> void:
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
