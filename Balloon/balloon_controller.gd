extends RigidBody3D
class_name BalloonController

# Balloon objects
var objs_in_balloon: Array[InteractionComponent] = []
var obj_weights: Array[float] = []
@export var basket_size: Vector3 = Vector3(5, 3, 5)

# Forces
@onready var oven: Oven = %Oven
var verticle_dir := -1
@export var verticle_force := 5.0
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
var player_weight := 1.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	_update_objects_list()

func _physics_process(_delta: float) -> void:
	_update_objects_list()
	_apply_vertical_force()
	_apply_horizontal_force()

func _update_objects_list() -> void:
	var raw_nodes: Array[Node] = get_tree().get_nodes_in_group("interactable")

	objs_in_balloon.clear()
	obj_weights.clear()

	for node in raw_nodes:
		if node is InteractionComponent and node != self:
			var obj: InteractionComponent = node
			var rel_pos = obj.object_ref.global_position - global_position

			# Check inside bounding box (centered on balloon)
			if abs(rel_pos.x) <= basket_size.x * 0.5 \
			and abs(rel_pos.y) <= basket_size.y * 0.5 \
			and abs(rel_pos.z) <= basket_size.z * 0.5:
				objs_in_balloon.append(obj)

	## Maybe add switch, door and basket if needed?
	for obj in objs_in_balloon:
		if "weight" in obj:
			obj_weights.append(obj.weight)
		else:
			obj_weights.append(1.0)

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

func change_verticle_direction(up: bool) -> void:
	verticle_dir = 1 if up else -1

func _apply_vertical_force() -> void:
	if oven: apply_central_force(Vector3.UP * verticle_dir * verticle_force * oven.get_fuel_percentage())
	is_on_ground = ground_checks.any(func(gc): return gc.is_colliding())
	if is_on_ground and verticle_dir < 0:
		verticle_dir = 0

func _apply_horizontal_force() -> void:
	if is_on_ground:
		_tilt_to(Vector3.ZERO)
		return

	var final_tilt = _compute_weighted_tilt()
	# tilt_velocity = tilt_velocity.lerp(final_tilt, horizontal_damping) ## smoother but less responsive
	_tilt_to(final_tilt)

	var horizontal_dir = Vector3(final_tilt.z, 0, final_tilt.x).normalized()
	if horizontal_dir.length() > move_threshold:
		apply_central_force(horizontal_dir * horizontal_force)

	if player:
		player.apply_sway(final_tilt)

func _compute_weighted_tilt() -> Vector3:
	if objs_in_balloon.is_empty() or obj_weights.is_empty():
		return Vector3.ZERO

	var total_influence = Vector3.ZERO
	var total_weight = 0.0

	for i in range(objs_in_balloon.size()):
		var obj : InteractionComponent = objs_in_balloon[i]
		if not obj: continue
		var weight = obj_weights[i]

		var rel_pos = obj.object_ref.global_position - global_position

		# normalize into -1..1 for X/Z
		var x_dir = clamp(rel_pos.x, -1.0, 1.0)
		var z_dir = clamp(rel_pos.z, -1.0, 1.0)

		# contribution = weight * relative position
		total_influence += Vector3(z_dir * weight, 0.0, -x_dir * weight)
		total_weight += weight

	if total_weight > 0:
		var avg_influence = total_influence / total_weight
		var target_x_rot = avg_influence.x * max_tilt_angle
		var target_z_rot = avg_influence.z * max_tilt_angle
		return Vector3(deg_to_rad(target_x_rot), 0.0, deg_to_rad(target_z_rot))

	return Vector3.ZERO

func _tilt_to(target_rot: Vector3):
	if tilt_tween:
		tilt_tween.kill()

	tilt_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tilt_tween.tween_property(mesh, "rotation", target_rot, tilt_damping)
