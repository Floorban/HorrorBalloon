extends Resource
class_name CaveVoxelData

@export var voxel_type: String = "dirt"
@export var tool_type: String = "pickaxe"
@export var texture_index: int = 0
@export var base_hp: int = 1

@export var min_height: float
@export var max_height: float

# neighbors dictionary: key = id, value = chance weight
@export var neighbor_chances: Dictionary = {}
@export var ores: Dictionary = {}

func get_random_neighbor(incremental_chance: float = 1.0) -> int:
	var total_weight = 0.0
	for weight in neighbor_chances.values():
		total_weight += weight * incremental_chance

	if total_weight <= 0.0:
		return texture_index

	var r = randf() * total_weight
	for neighbor_index in neighbor_chances.keys():
		r -= neighbor_chances[neighbor_index] * incremental_chance
		if r <= 0:
			return neighbor_index

	return texture_index

func get_random_ore() -> String:
	var total = 0.0
	for p in ores.values():
		total += p
	var r = randf() * total
	for ore in ores.keys():
		r -= ores[ore]
		if r <= 0:
			return ore
	return ""  # no ore
