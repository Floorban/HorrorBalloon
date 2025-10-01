extends EnemyState

@export var search_time := 10.0
@export var _searching_speed := 6.0
@export var _search_radius := 10.0

var _search_timer := 0.0
var _player_last_seen_position: Vector3

var _last_seen_tick: float = 0.0

func enter(_previous_state_name: String, data := {}) -> void:
	_search_timer = search_time
	_last_seen_tick = Time.get_ticks_msec() / 1000.0
	if data["player_last_seen_position"]:
		_player_last_seen_position = data["player_last_seen_position"]
	else:
		printerr("State 'Searching' was not given the player's last seen position through the data dictionary.")
		
	_search_timer = search_time
	_go_to_position_around_player_last_seen_position()

func update(delta: float) -> void:
	_search_timer -= delta
	var time_since_seen = (Time.get_ticks_msec() / 1000.0) - _last_seen_tick
	if _search_timer <= 0.0 and time_since_seen > 2.0:
		requested_transition_to_other_state.emit("Roaming", {"do_not_reset_path": true})

func physics_update(_delta: float) -> void:
	if _enemy.navigation_agent.is_navigation_finished():
		_go_to_position_around_player_last_seen_position()
	if not _enemy.is_line_of_sight_broken():
		_last_seen_tick = Time.get_ticks_msec() / 1000.0
		requested_transition_to_other_state.emit("Chasing")

func _go_to_position_around_player_last_seen_position() -> void:
	var random_position := _player_last_seen_position + _get_random_position_inside_circle(_search_radius, _player_last_seen_position.y)
	_enemy.travel_to_position(random_position, _searching_speed, true)

func _get_random_position_inside_circle(radius: float, height: float) -> Vector3:
	var tries := 5
	while tries > 0:
		var theta: float = randf() * 2 * PI
		var offset := Vector3(cos(theta), 0, sin(theta)) * sqrt(randf()) * radius
		var pos := _player_last_seen_position + offset
		var nav_map := _enemy.get_world_3d().get_navigation_map()
		if NavigationServer3D.map_get_closest_point(nav_map, pos).distance_to(pos) < 1.0:
			pos.y = height
			return pos
		tries -= 1
	return _player_last_seen_position
