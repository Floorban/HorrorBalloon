extends RigidBody3D
class_name BalloonController

@onready var obj_in_balloon_area: Area3D = %ObjInBalloonArea
var objs_in_balloon: Dictionary = {}

# Forces
const GRAVITY = 0.1
@onready var oven: Oven = %Oven
var verticle_dir := -1.0
var total_weight : float
@export var verticle_base_force := 10.0
var verticle_force : float
@export var horizontal_force := 2.0
var move_threshold := 0.1

# Tilt
var horizontal_dir: Vector3
@onready var mesh: Node3D = $Mesh
@export var max_tilt_angle := 8.0
var tilt_tween : Tween
var tilt_velocity := Vector3.ZERO
var tilt_damping := 0.5
var tilt_threshold := 0.005

@onready var land_checks: = [%GroundCheck_6, %GroundCheck_7, %GroundCheck_8, %GroundCheck_9, %GroundCheck_10]
@onready var ground_checks := [%GroundCheck_1, %GroundCheck_2, %GroundCheck_3, %GroundCheck_4, %GroundCheck_5]
var can_land := false
var is_on_ground := false

var player: PlayerController
var player_weight := 10.0
var is_just_land: = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	objs_in_balloon.clear()
	obj_in_balloon_area.body_entered.connect(_on_body_entered)
	obj_in_balloon_area.body_exited.connect(_on_body_exited)

func _physics_process(_delta: float) -> void:
	can_land = land_checks.any(func(gc): return gc.is_colliding())
	is_on_ground = ground_checks.any(func(gc): return gc.is_colliding())
	if can_land and linear_velocity.y <= 0.0:
		linear_velocity = Vector3.ZERO
		gravity_scale = 0.0

	if is_on_ground or can_land:
		if verticle_dir < 0.0:
			if not is_just_land and linear_velocity.y <= 0.0:
				player.trauma = 0.5
				is_just_land = true
			verticle_dir = 0.0
			gravity_scale = 0.0
			return
	else:
		gravity_scale = GRAVITY
		is_just_land = false

	_apply_vertical_force()
	_apply_horizontal_force()

func execute(percentage: float) -> void:
	## For Switch
	if percentage > 0.99:
		change_verticle_direction(true)
	elif percentage < 0.01:
		change_verticle_direction(false)
	
	## For Rope
	if tilt_tween:
		tilt_tween.kill()

	tilt_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tilt_tween.tween_property(self, "rotation:y", percentage, 10.0)

var _is_reparenting := false

func _on_body_entered(body: Node3D) -> void:
	if _is_reparenting:
		return
	if body == player:
		objs_in_balloon[body] = player_weight
		# _is_reparenting = true
		# call_deferred("_deferred_attach", player)
	if body.is_in_group("interactable"):
		var obj = body.get_node_or_null("InteractionComponent")
		if obj and "weight" in obj:
			objs_in_balloon[body] = obj.weight
			_is_reparenting = true
			call_deferred("_deferred_attach", body)
	total_weight = get_all_weights()

func _on_body_exited(body: Node3D) -> void:
	if _is_reparenting:
		return
	if body == player or body.is_in_group("interactable"):
		_is_reparenting = true
		call_deferred("_deferred_deattach", player)
	if objs_in_balloon.has(body):
		objs_in_balloon.erase(body)

	total_weight = get_all_weights()

func _deferred_attach(body: Node3D):
	if not body:
		_is_reparenting = false
		return
	var parent : Node = body.get_parent()
	if parent == self:
		_is_reparenting = false
		return

	var old_transform: Transform3D = body.global_transform

	if obj_in_balloon_area:
		obj_in_balloon_area.monitoring = false

	if parent:
		parent.remove_child(body)
	add_child(body)

	body.global_transform = old_transform

	if obj_in_balloon_area:
		obj_in_balloon_area.monitoring = true
	_is_reparenting = false


func _deferred_deattach(body: Node3D):
	if not body:
		_is_reparenting = false
		return
	var current_scene : Node = get_tree().current_scene
	var parent = body.get_parent()
	if parent == current_scene:
		_is_reparenting = false
		return

	var old_transform: Transform3D = body.global_transform

	if obj_in_balloon_area:
		obj_in_balloon_area.monitoring = false

	if parent:
		parent.remove_child(body)
	current_scene.add_child(body)

	body.global_transform = old_transform

	if obj_in_balloon_area:
		obj_in_balloon_area.monitoring = true
	_is_reparenting = false

func change_verticle_direction(up: bool) -> void:
	verticle_dir = 1.0 if up else -0.2

func _apply_vertical_force() -> void:
	verticle_force = verticle_base_force # - get_all_weights() / 20.0
	if oven: apply_central_force(Vector3.UP * verticle_dir * verticle_force * oven.get_fuel_percentage())

func _apply_horizontal_force() -> void:
	if is_on_ground or can_land:
		_tilt_to(Vector3.ZERO, tilt_damping * 2.0)
		return

	var final_tilt = _compute_weighted_tilt()
	_tilt_to(final_tilt, tilt_damping)

	horizontal_dir = Vector3(-final_tilt.z, 0, final_tilt.x).normalized()
	if horizontal_dir.length() > move_threshold:
		apply_central_force(horizontal_dir * horizontal_force)

	if player:
		player.apply_sway(final_tilt)

func get_all_weights() -> float:
	if objs_in_balloon.is_empty():
		return 0.0
	return objs_in_balloon.values().reduce(func(a, b): return a + b, 0.0)

func _compute_weighted_tilt() -> Vector3:
	if objs_in_balloon.is_empty():
		return Vector3.ZERO
		
	var total_influence = Vector3.ZERO
	var weight_sum = 0.0
		
	for obj in objs_in_balloon.keys():
		if not obj:
			continue
		var weight: float = objs_in_balloon[obj]
		
		var rel_pos_local = to_local(obj.global_transform.origin)

		if obj is InteractionComponent:
			rel_pos_local = obj.object_ref.global_position - global_position
		
		var x_dir = clamp(rel_pos_local.x, -1.0, 1.0)
		var z_dir = clamp(rel_pos_local.z, -1.0, 1.0)
		
		total_influence += Vector3(z_dir * weight, 0.0, -x_dir * weight)
		weight_sum += weight
		
	if weight_sum > 0:
		var avg_influence = total_influence / weight_sum
		var target_x_rot = avg_influence.x * max_tilt_angle
		var target_z_rot = avg_influence.z * max_tilt_angle
		return Vector3(deg_to_rad(target_x_rot), 0.0, deg_to_rad(target_z_rot))

	return Vector3.ZERO

func _tilt_to(target_rot: Vector3, damping: float):
	if tilt_tween:
		tilt_tween.kill()
		
	var new_rot = mesh.rotation
	new_rot.x = target_rot.x
	new_rot.z = target_rot.z

	tilt_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tilt_tween.tween_property(mesh, "rotation", new_rot, damping)
