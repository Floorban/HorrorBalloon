extends CharacterBody3D
class_name Enemy

signal reached_player

@export var max_spotting_distance := 50.0
@export var fov_dot_threshold := 0.3

var _current_speed := 0.0

@onready var navigation_agent: NavigationAgent3D = %NavigationAgent3D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var player: PlayerController = get_tree().get_first_node_in_group("player")
@onready var _eye: Node3D = %Eye
@onready var player_check: RayCast3D = $Eye/PlayerCheck

var found_target := false
var last_seen_position: Vector3
var last_seen_time: float = 0.0

func _ready() -> void:
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)

func _physics_process(_delta: float) -> void:
	if found_target:
		return

	if navigation_agent.is_navigation_finished():
		animation_player.play("IDLE", 0.2)
		return
	
	var next_path_position := navigation_agent.get_next_path_position()
	var where_to_look := next_path_position
	where_to_look.y = global_position.y
	if not where_to_look.is_equal_approx(global_position):
		look_at(where_to_look)

	var direction := next_path_position - global_position
	direction.y = 0.0
	direction = direction.normalized()
	velocity = direction * _current_speed
	move_and_slide()

func travel_to_position(wanted_position: Vector3, speed: float, play_run_anim := false) -> void:
	if found_target:
		return
	navigation_agent.target_position = wanted_position
	_current_speed = speed
	if play_run_anim:
		animation_player.play("HIT")
	else:
		animation_player.play("RUN")

func is_player_in_view() -> bool:
	var vec_to_player := (player.global_position - global_position)
	
	if vec_to_player.length() > max_spotting_distance:
		return false
	
	var in_fov := -_eye.global_basis.z.normalized().dot(vec_to_player.normalized()) > 0.3
	if in_fov:
		return not is_line_of_sight_broken()
	
	return false

func is_line_of_sight_broken() -> bool:
	player_check.target_position = player_check.to_local(player.global_position)
	player_check.force_raycast_update()
	return player_check.is_colliding()

func reached_target():
	found_target = true
	reached_player.emit()
	animation_player.play("ATK")
	play_jumpscare()

func play_jumpscare():
	$Audio/Jumpscare.play_one_shot()

func _exit_tree() -> void:
	$Audio/Jumpscare.stop()
	$Audio/Jumpscare.queue_free()
	
	$Audio/Screech.stop()
	$Audio/Screech.queue_free()
