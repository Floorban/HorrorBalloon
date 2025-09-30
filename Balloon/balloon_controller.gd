extends RigidBody3D
class_name BalloonController

@onready var player: PlayerController = get_tree().get_first_node_in_group("player")
@onready var oven: Node = %Oven
@onready var balloon_body: Node3D = $Body

@onready var obj_in_balloon_area: Area3D = %ObjInBalloonArea
var _is_reparenting := false
@onready var ground_checks := [%GroundCheck_1, %GroundCheck_2, %GroundCheck_3, %GroundCheck_4, %GroundCheck_5]
var is_on_ground := false

# weight / objects in balloon
var objs_in_balloon: Dictionary = {}
var total_weight: float = 0.0
var player_weight: float = 10.0

# vertical
const GRAVITY := 1.0
@export var vertical_base_force: float = 10.0
var vertical_force: float = 0.0
var locked_vertical := false
var is_just_land : = false

# horizontal
@export var horizontal_force: float = 2.0
var move_threshold := 0.1
var horizontal_dir: Vector3 = Vector3.ZERO

# tilt
@export var max_tilt_angle := 8.0 # degrees
var tilt_tween: Tween = null
var tilt_damping := 0.5

func _ready() -> void:
	objs_in_balloon.clear()
	if obj_in_balloon_area:
		obj_in_balloon_area.body_entered.connect(_on_body_entered)
		obj_in_balloon_area.body_exited.connect(_on_body_exited)

func _physics_process(_delta: float) -> void:
	# is_on_ground = ground_checks.any(func(gc): return gc and gc.is_colliding())
	
	# # landing
	# if is_on_ground:
	# 	if not is_just_land:
	# 		player.trauma = 0.8
	# 		is_just_land = true
	# 		locked_vertical = true
	# else:
	# 	is_just_land = false

	# # takeoff condition
	# if is_on_ground and is_just_land and oven.get_fuel_percentage() > 0.5:
	# 	player.trauma = 0.5
	# 	is_just_land = false
	# 	locked_vertical = false
	# 	# impulse to break ground contact
	# 	apply_central_impulse(Vector3.UP * 2.0)

	_apply_vertical_force()
	_apply_horizontal_force()

func _apply_vertical_force() -> void:
	if locked_vertical:
		return

	var fuel_mult : float = oven.get_fuel_percentage() if oven and oven.has_method("get_fuel_percentage") else 0.0
	vertical_force = vertical_base_force * fuel_mult # - (GRAVITY * total_weight * 0.05)
	apply_central_force(Vector3.UP * vertical_force)

func _apply_horizontal_force() -> void:
	# Stop horizontal motion if grounded
	if is_on_ground:
		_tilt_to(Vector3.ZERO, tilt_damping * 2.0)
		horizontal_dir = Vector3.ZERO
		return

	var final_tilt: Vector3 = _compute_weighted_tilt()
	_tilt_to(final_tilt, tilt_damping)

	horizontal_dir = Vector3(-final_tilt.z, 0.0, final_tilt.x).normalized()

	if horizontal_dir.length() > move_threshold:
		var target_force = horizontal_dir * horizontal_force
		apply_central_force(target_force)

	if player and player.has_method("apply_sway"):
		player.apply_sway(final_tilt)

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

		total_influence += Vector3(z_dir * weight, 0.0, -x_dir * weight)
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

func _on_body_entered(body: Node3D) -> void:
	if _is_reparenting:
		return
	if body == player:
		objs_in_balloon[body] = player_weight
		_is_reparenting = true
		call_deferred("_deferred_attach", player)
	if body.is_in_group("interactable"):
		var obj = body.get_node_or_null("InteractionComponent")
		if obj and "weight" in obj:
			objs_in_balloon[body] = obj.weight
			_is_reparenting = true
			call_deferred("_deferred_attach", body)
	total_weight = _get_all_weights()

func _on_body_exited(body: Node) -> void:
	if _is_reparenting or not body:
		return

	if body == player:
		if objs_in_balloon.has(body):
			objs_in_balloon.erase(body)
		total_weight = _get_all_weights()
		return

	if body.is_in_group("interactable"):
		_is_reparenting = true
		call_deferred("_deferred_deattach", body)

	if objs_in_balloon.has(body):
		objs_in_balloon.erase(body)

	total_weight = _get_all_weights()

func _deferred_attach(body: Node) -> void:
	_is_reparenting = true
	if not body:
		_is_reparenting = false
		return

	if body.get_parent() == self:
		_is_reparenting = false
		return

	var old_transform: Transform3D = body.global_transform

	if obj_in_balloon_area:
		obj_in_balloon_area.monitoring = false

	var parent = body.get_parent()
	if parent:
		parent.remove_child(body)
	add_child(body)

	body.global_transform = old_transform

	if obj_in_balloon_area:
		obj_in_balloon_area.monitoring = true

	_is_reparenting = false

func _deferred_deattach(body: Node) -> void:
	_is_reparenting = true
	if not body:
		_is_reparenting = false
		return

	var current_scene: Node = get_tree().current_scene
	if body.get_parent() == current_scene:
		_is_reparenting = false
		return

	var old_transform: Transform3D = body.global_transform

	if obj_in_balloon_area:
		obj_in_balloon_area.monitoring = false

	var parent = body.get_parent()
	if parent:
		parent.remove_child(body)
	current_scene.add_child(body)

	body.global_transform = old_transform

	if obj_in_balloon_area:
		obj_in_balloon_area.monitoring = true

	_is_reparenting = false

# Called externally to rotate the balloon with rope
func execute(percentage: float) -> void:
	if tilt_tween: tilt_tween.kill()
	tilt_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tilt_tween.tween_property(self, "rotation:y", percentage, 10.0)
