extends RigidBody3D
class_name BalloonController

@onready var obj_in_balloon_area: Area3D = $Mesh/ObjInBalloonArea
var objs_in_balloon: Dictionary = {}
@export var basket_size: Vector3 = Vector3(5, 3, 5)

# Forces
@onready var oven: Oven = %Oven
var verticle_dir := -1
var total_weight : float
@export var verticle_base_force := 5.0
var verticle_force : float
@export var horizontal_force := 2.0
var move_threshold := 0.1

# Tilt
@onready var mesh: Node3D = $Mesh
@export var max_tilt_angle := 8.0
var tilt_tween : Tween
var tilt_velocity := Vector3.ZERO
var tilt_damping := 0.5
var tilt_threshold := 0.005

@onready var ground_checks := [$GroundCheck_1, $GroundCheck_2, $GroundCheck_3, $GroundCheck_4, $GroundCheck_5]
var is_on_ground := false

var player: PlayerController
var player_weight := 15.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	objs_in_balloon.clear()
	obj_in_balloon_area.body_entered.connect(_on_body_entered)
	obj_in_balloon_area.body_exited.connect(_on_body_exited)

func _physics_process(_delta: float) -> void:
	#_update_objects_list()
	_apply_vertical_force()
	_apply_horizontal_force()

#func _update_objects_list() -> void:
	#var raw_nodes: Array[Node] = get_tree().get_nodes_in_group("interactable")
	#objs_in_balloon.clear()
#
	#for node in raw_nodes:
		#var rel_pos : Vector3 = Vector3.ZERO
		#if node is InteractionComponent:
			#rel_pos = node.object_ref.global_position - global_position
		#else:
			#rel_pos = node.global_position - global_position
#
		## Check inside bounding box (centered on balloon)
		#if abs(rel_pos.x) <= basket_size.x * 0.5 \
		#and abs(rel_pos.y) <= basket_size.y * 0.5 \
		#and abs(rel_pos.z) <= basket_size.z * 0.5:
			#var weight := 1.0
			#if node == player:
				#weight = player_weight
			#elif node.has_method("weight"):
				#weight = node.weight
			#objs_in_balloon[node] = weight
#
#func execute(percentage: float) -> void:
	#if percentage > 0.99:
		#change_verticle_direction(true)
	#elif percentage < 0.01:
		#change_verticle_direction(false)
#
	#if tilt_tween:
		#tilt_tween.kill()
#
	#tilt_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	#tilt_tween.tween_property(self, "rotation:y", percentage, 1.0)

func execute(percentage: float) -> void:
	## For Switch
	if percentage > 0.99:
		change_verticle_direction(true)
	elif percentage < 0.01:
		change_verticle_direction(false)
	
	## For Rope
	# rotate_y(percentage)

	if tilt_tween:
		tilt_tween.kill()

	tilt_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tilt_tween.tween_property(self, "rotation:y", percentage, 1.0)

func _on_body_entered(body: Node) -> void:
	if body == player:
		objs_in_balloon[body] = player_weight
	elif body.get_node_or_null("InteractionComponent"):
		var interactable : InteractionComponent = body.get_node_or_null("InteractionComponent")
		if interactable.is_in_group("interactable"):
			objs_in_balloon[body] = interactable.weight
		
	if body.get_parent() != self:
			body.call_deferred("reparent", self, true)
	total_weight = get_all_weights()

func _on_body_exited(body: Node) -> void:
	var current_scene : Node = get_tree().current_scene
	if objs_in_balloon.has(body):
		objs_in_balloon.erase(body)
		
	if body.get_parent() != current_scene:
		body.call_deferred("reparent", current_scene)
	total_weight = get_all_weights()

func change_verticle_direction(up: bool) -> void:
	verticle_dir = 1 if up else -1

func _apply_vertical_force() -> void:
	verticle_force = verticle_base_force - total_weight / 10.0
	if oven: apply_central_force(Vector3.UP * verticle_dir * verticle_force * oven.get_fuel_percentage())
	is_on_ground = ground_checks.any(func(gc): return gc.is_colliding())
	if is_on_ground and verticle_dir < 0:
		verticle_dir = 0

func _apply_horizontal_force() -> void:
	if is_on_ground:
		_tilt_to(Vector3.ZERO)
		return

	var final_tilt = _compute_weighted_tilt()
	_tilt_to(final_tilt)

	var horizontal_dir = Vector3(final_tilt.z, 0, final_tilt.x).normalized()
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
		
		var rel_pos : Vector3 = obj.global_position - global_position
		if obj is InteractionComponent:
			rel_pos = obj.object_ref.global_position - global_position
		
		var x_dir = clamp(rel_pos.x, -1.0, 1.0)
		var z_dir = clamp(rel_pos.z, -1.0, 1.0)
		
		total_influence += Vector3(z_dir * weight, 0.0, -x_dir * weight)
		weight_sum += weight
		
	if weight_sum > 0:
		var avg_influence = total_influence / weight_sum
		var target_x_rot = avg_influence.x * max_tilt_angle
		var target_z_rot = avg_influence.z * max_tilt_angle
		return Vector3(deg_to_rad(target_x_rot), 0.0, deg_to_rad(target_z_rot))

	return Vector3.ZERO

func _tilt_to(target_rot: Vector3):
	if tilt_tween:
		tilt_tween.kill()

	tilt_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tilt_tween.tween_property(mesh, "rotation", target_rot, tilt_damping)
