@tool
extends Node3D
class_name ResourceSpawner

@export var resource_spawn_data: Array[ResourceSpawnData] = []
@export var spawn_points : Node
var resource_spawn_points: Array[SpawnPoint] = []

@export var generate_preview: bool = false:
	set(value):
		generate_preview = value
		if Engine.is_editor_hint() and value:
			_on_generate_preview_pressed()
			generate_preview = false

@export var map_size := 200.0
@export var jitter_amount := 0.3

func _on_generate_preview_pressed():
	spawn_resources()

func _ready() -> void:
	spawn_resources()

func _get_spawn_points():
	resource_spawn_points.clear()
	if not spawn_points: return
	for child in spawn_points.get_children():
		if child is SpawnPoint:
			resource_spawn_points.append(child)

func poisson_sample_points(area_size := 400.0, min_distance := 30.0, max_attempts := 30) -> Array[Vector3]:
	var points: Array[Vector3] = []
	var _spawn_points: Array[Vector3] = []
	
	var start := Vector3(randf_range(-area_size/2, area_size/2), 0, randf_range(-area_size/2, area_size/2))
	points.append(start)
	_spawn_points.append(start)
	
	while spawn_points.size() > 0:
		var spawn_index := randi() % _spawn_points.size()
		var spawn_center := _spawn_points[spawn_index]
		var candidate_found := false
		
		for i in max_attempts:
			var angle := randf() * TAU
			var radius := randf_range(min_distance, 2 * min_distance)
			var candidate := spawn_center + Vector3(cos(angle), 0, sin(angle)) * radius
			
			if abs(candidate.x) > area_size/2 or abs(candidate.z) > area_size/2:
				continue # outside bounds
			
			var valid := true
			for p in points:
				if p.distance_to(candidate) < min_distance:
					valid = false
					break
			
			if valid:
				points.append(candidate)
				_spawn_points.append(candidate)
				candidate_found = true
				break
		
		if not candidate_found:
			_spawn_points.remove_at(spawn_index)
	return points

var max__spawn_attempts := 500

func distribute_spawn_points(points: Array[SpawnPoint], _map_size := 400.0, _jitter := 0.3):
	if points.is_empty(): return
	var half_map := _map_size / 2.0
	var center := global_position

	for sp in points:
		var valid := false
		var attempt := 0

		while not valid and attempt < max__spawn_attempts:
			attempt += 1
			var rand_x = randf_range(-half_map, half_map)
			var rand_y = randf_range(-half_map, half_map)
			var rand_z = randf_range(-half_map, half_map)
			var candidate_pos = Vector3(rand_x, rand_y, rand_z) + center
			# retry if fail spawn conditions:
			var dist_to_center := Vector2(candidate_pos.x,candidate_pos.z).distance_to(Vector2(center.x,center.z))
			if candidate_pos.y < CaveConstants.CAVE_TOP and dist_to_center > CaveConstants.CAVE_MIN_WIDTH:
				valid = true
				sp.global_position = candidate_pos
		if not valid:
			push_warning("spawn point failed to find valid position after %d attempts" % max__spawn_attempts)

func spawn_resources() -> void:
	_get_spawn_points()
	randomize()
	distribute_spawn_points(resource_spawn_points, map_size, jitter_amount)
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
			
			# add anther weight-bsed scene selection here later (based on ore spawn condition)
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
