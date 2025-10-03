extends CharacterBody3D
class_name Enemy

signal reached_player

@export var max_spotting_distance := 30.0
@export var fov_dot_threshold := 0.3

var _current_speed := 0.0

@onready var navigation_agent: NavigationAgent3D = %NavigationAgent3D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var player: PlayerController = get_tree().get_first_node_in_group("player")
@onready var _eye: Node3D = %Eye

var found_target := false
var last_seen_position: Vector3
var last_seen_time: float = 0.0

@export var _trauma_interval := 10
@export var _shake_radius := 50.0
@export var _max_trauma := 1.5
var _trauma_timer := 0.0

func _ready() -> void:
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)

func _process(delta: float) -> void:
	_trauma_timer -= delta
	if _trauma_timer <= 0.0:
		_trauma_timer = _trauma_interval
		var dist := global_position.distance_to(player.global_position)
		if dist <= _shake_radius:
			var normalized : float = clamp((_shake_radius - dist) / _shake_radius, 0.0, 1.0)
			var trauma_strength := pow(normalized, 2.5)
			var spike := trauma_strength * _max_trauma
			player.trauma = clamp(player.trauma + spike, 0.0, 1.0)

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
	else:	
		return true

func reached_target():
	$Audio/Screech.stop()
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
