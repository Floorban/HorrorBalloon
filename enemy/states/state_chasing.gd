extends EnemyState

@export var chase_max_time := 8.0
@export var update_path_delay := 0.0
@export var _chasing_speed := 4.0
@export var _catching_distance := 3.0

var _chase_timer := 0.0
var _update_path_timer := 0.0
var is_attacking := false

@export var _trauma_interval := 1.2
@export var _shake_radius := 50.0
@export var _max_trauma := 2.5
var _trauma_timer := 0.0

## Sound Settings
var audio: AudioManager
@onready var e_screech: FmodEventEmitter3D = $"../../Audio/Screech"
var anxiety := "Anxiety"
var guilt := "Guilt"
var hatred := "Hatred"
var terror := "Terror"
@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	audio = get_tree().get_first_node_in_group("audio")
	audio.cache(e_screech, $"../..".global_position)
	e_screech.set_parameter(anxiety, rng.randf_range(0.0, 100.0))
	e_screech.set_parameter(guilt, rng.randf_range(0.0, 100.0))
	e_screech.set_parameter(hatred, rng.randf_range(0.0, 100.0))
	e_screech.set_parameter(terror, rng.randf_range(0.0, 100.0))

func enter(_previous_state_name: String, _data := {}) -> void:
	_chase_timer = chase_max_time
	e_screech.play()

func update(delta: float) -> void:
	_update_path_timer -= delta
	_chase_timer -= delta
	if _chase_timer <= 0.0:
		requested_transition_to_other_state.emit("Searching", {"player_last_seen_position": _enemy.player.global_position})
		
	_trauma_timer -= delta
	if _trauma_timer <= 0.0:
		_trauma_timer = _trauma_interval
		var dist := _enemy.global_position.distance_to(_enemy.player.global_position)
		if dist <= _shake_radius:
			var normalized : float = clamp((_shake_radius - dist) / _shake_radius, 0.0, 1.0)
			var trauma_strength := pow(normalized, 2.5)
			var spike := trauma_strength * _max_trauma
			_enemy.player.trauma = clamp(_enemy.player.trauma + spike, 0.0, 1.0)

func physics_update(_delta: float) -> void:
	if _update_path_timer <= 0.0:
		_update_path_timer = update_path_delay
		_enemy.travel_to_position(_enemy.player.global_position, _chasing_speed, true)
	if not _enemy.is_line_of_sight_broken():
		_chase_timer = chase_max_time
	if _enemy.global_position.distance_to(_enemy.player.global_position) <= _catching_distance:
		_enemy.reached_target()
		_chasing_speed = 0.0
