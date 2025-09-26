extends Node3D

@export var resource_scenes: Array[PackedScene] = []
@export var resource_spawn_points: Array[Node3D] = []

@export var island_scenes: Array[PackedScene] = []
@export var island_spawn_points: Array[Node3D] = []

@onready var enemy : Enemy = get_tree().get_first_node_in_group("enemy")
@onready var player : PlayerController = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	enemy.reached_player.connect(Callable(game_over))
	generate_resource()
	generate_islands()

func generate_resource():
	if resource_spawn_points.size() <= 0: return
	randomize()
	for point in resource_spawn_points:
		if resource_scenes.size() > 0:
			var scene_to_spawn = resource_scenes.pick_random()
			var instance = scene_to_spawn.instantiate()
			instance.global_transform = point.global_transform
			add_child(instance)

func generate_islands():
	if island_spawn_points.size() <= 0: return
	randomize()
	for point in island_spawn_points:
		if island_scenes.size() > 0:
			var scene_to_spawn = island_scenes.pick_random()
			var instance = scene_to_spawn.instantiate()
			instance.global_transform = point.global_transform
			add_child(instance)

func game_over():
	print("game over")