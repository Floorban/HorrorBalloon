extends RigidBody3D
class_name BalloonController

@export var verticle_force := 5.0
@export var horizontal_force := 2.0

@onready var mesh: Node3D = $Mesh
@export var max_tilt_angle := 8.0
var tilt_tween : Tween

var move_threshold := 0.1
var tilt_threshold := 0.005
var tilt_damping := 0.5

@onready var oven: Oven = %Oven
var verticle_dir := -1
@onready var ground_checks := [$GroundCheck_1, $GroundCheck_2, $GroundCheck_3, $GroundCheck_4, $GroundCheck_5]
var is_on_ground := false

@export var tilt_objects: Array[Node3D] = []
@export var object_weights: Array[float] = []
var player : PlayerController
var prev_velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float):
	_apply_vertical_force()
	_apply_horizontal_force()

func execute(percentage: float) -> void:
	if percentage > 0.99:
		change_verticle_direction(true)
	elif percentage < 0.01:
		change_verticle_direction(false)

func change_verticle_direction(up : bool) -> void:
	if up: verticle_dir = 1
	else: verticle_dir = -1

func _apply_vertical_force():
	if oven: apply_central_force(Vector3.UP * verticle_dir * verticle_force * oven.get_fuel_percentage())
	is_on_ground = ground_checks.any(func(gc): return gc.is_colliding())
	if is_on_ground and verticle_dir < 0:
		verticle_dir = 0

func _apply_horizontal_force():
	if is_on_ground:
		_tilt_to(Vector3.ZERO)
		return

	var final_tilt = _compute_weighted_tilt()
	_tilt_to(final_tilt)

	var horizontal_dir = Vector3(final_tilt.z, 0, final_tilt.x).normalized()
	if horizontal_dir.length() > move_threshold:
		apply_central_force(horizontal_dir * horizontal_force)

	if player: player.apply_sway(final_tilt)


func _compute_weighted_tilt() -> Vector3:
	if tilt_objects.is_empty() or object_weights.is_empty():
		return Vector3.ZERO

	var total_influence = Vector3.ZERO
	var total_weight = 0.0

	for i in range(tilt_objects.size()):
		var obj = tilt_objects[i]
		if not obj: continue
		var weight = object_weights[i]

		var rel_pos = obj.global_position - global_position

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
