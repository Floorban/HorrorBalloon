extends Node3D

@export var resource_spawner: ResourceSpawner
@export var island_scenes: Array[PackedScene] = []
@export var island_spawn_points: Array[Node3D] = []

@onready var enemy: Enemy = get_tree().get_first_node_in_group("enemy")
@onready var player: PlayerController = get_tree().get_first_node_in_group("player")
@onready var balloon: BalloonController = get_tree().get_first_node_in_group("balloon")
@export var default_resource: Node3D

func _ready() -> void:
	if enemy: enemy.reached_player.connect(game_over)
	randomize()
	resource_spawner.spawn_resources()
	generate_islands()
	var area_size := 150.0
	var spawn_pos = _get_random_point(area_size) 
	balloon.global_position = spawn_pos
	player.global_position = spawn_pos
	default_resource.global_position = spawn_pos + Vector3.RIGHT * 5

func _get_random_point(area_size: float, avoid_radius: float = 50.0) -> Vector3:
	var half := area_size / 2.0
	var x := 0.0
	var z := 0.0
	while true:
		x = randf_range(-half, half)
		z = randf_range(-half, half)
		if Vector2(x, z).length() >= avoid_radius:
			break
	var y := 5.0
	return Vector3(x, y, z)

func generate_islands() -> void:
	if island_spawn_points.is_empty() or island_scenes.is_empty():
		return
	randomize()
	for point in island_spawn_points:
		var scene_to_spawn = island_scenes.pick_random()
		if scene_to_spawn == null:
			continue
		var instance = scene_to_spawn.instantiate()
		instance.global_transform = point.global_transform
		add_child(instance)

func game_over() -> void:
	print("game over")
	if player and enemy:
		player.trauma = 2.0
		player.play_death_animation(enemy._eye.global_position)
	await get_tree().create_timer(1.2).timeout
	get_tree().reload_current_scene()

func _on_dead_zone_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		game_over()
