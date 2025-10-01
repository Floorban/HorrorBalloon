extends Node
class_name ResourceSpawner

@export var resource_spawn_data: Array[ResourceSpawnData] = []
@onready var spawn_points := $"../ResourceSpawnPoints"
var resource_spawn_points: Array[SpawnPoint] = []

func _ready() -> void:
	_get_spawn_points()

func spawn_resources() -> void:
	randomize()
	generate_resources()

func _available_indices(remaining: Array) -> Array:
	var arr: Array = []
	for i in range(remaining.size()):
		if remaining[i] > 0:
			arr.append(i)
	return arr

func _pick_index_by_weight(indices: Array) -> int:
	if indices.is_empty():
		return -1
	var total := 0.0
	for idx in indices:
		total += resource_spawn_data[idx].weight
	var r := randf() * total
	var cur := 0.0
	for idx in indices:
		cur += resource_spawn_data[idx].weight
		if r <= cur:
			return idx
	return indices.back()

func _get_spawn_points():
	if not spawn_points: return
	for point in spawn_points.get_children():
		if point is SpawnPoint:
			resource_spawn_points.append(point)

func generate_resources() -> void:
	if resource_spawn_points.is_empty() or resource_spawn_data.is_empty():
		return
	
	var remaining: Array = []
	for data in resource_spawn_data:
		remaining.append(max(0, data.max_spawn))

	for i in range(resource_spawn_points.size()):
		var point = resource_spawn_points[i]
		var point_data = point.spawn_point_data
		var count = point_data.spawn_count
		var radius = point_data.spawn_radius

		for j in range(count):
			var available = _available_indices(remaining)
			if available.is_empty():
				return
			
			var idx = _pick_index_by_weight(available)
			if idx < 0:
				return
			var data = resource_spawn_data[idx]
			if data.scenes == null:
				remaining[idx] = 0
				continue

			var instance = data.scenes.pick_random().instantiate()
			point.add_child(instance)

			instance.global_position = point.global_position + Vector3(
				randf_range(-radius, radius),
				0.0,
				randf_range(-radius, radius))

			instance.global_rotation += Vector3(
				randf_range(deg_to_rad(-80), deg_to_rad(80)),
				randf_range(deg_to_rad(-80), deg_to_rad(80)),
				randf_range(deg_to_rad(-80), deg_to_rad(80)))

			remaining[idx] -= 1
