extends EnemyState

@export var _roaming_speed := 2.0

var _map_synchronized := false
var _nav_map: RID

var _chase_reaction_timer := 0.0
var _saw_player := false

func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	_map_synchronized = true
	_nav_map = _enemy.get_world_3d().get_navigation_map()
	var balloon := get_tree().get_first_node_in_group("balloon")
	if balloon and balloon.has_signal("has_landed"):
		balloon.has_landed.connect(_on_balloon_landed)

func enter(_previous_state_name: String, data := {}) -> void:
	if not _map_synchronized:
		return
	if data.has("do_not_reset_path") and data["do_not_reset_path"]:
		_enemy.travel_to_position(_enemy.navigation_agent.target_position, _roaming_speed)
		return
	_travel_to_random_position()

func physics_update(_delta: float) -> void:
	if not _map_synchronized:
		return
	if _enemy.navigation_agent.is_navigation_finished():
		_travel_to_random_position()
	if _enemy.is_player_in_view():
		if not _saw_player:
			_saw_player = true
			_chase_reaction_timer = 0.3
		else:
			_chase_reaction_timer -= _delta
			if _chase_reaction_timer <= 0.0:
				requested_transition_to_other_state.emit("Chasing")
	else:
		_saw_player = false

func _on_balloon_landed() -> void:
	if _enemy.found_target:
		return
	if _enemy and _enemy.player:
		var last_known_pos = _enemy.player.global_position
		_on_heard_noise(last_known_pos)

func _on_heard_noise(noise_position: Vector3) -> void:
	requested_transition_to_other_state.emit("Searching", {"player_last_seen_position": noise_position})

func _travel_to_random_position() -> void:
	var rand_pos := NavigationServer3D.map_get_random_point(_nav_map, 1, true)
	_enemy.travel_to_position(rand_pos, _roaming_speed)
