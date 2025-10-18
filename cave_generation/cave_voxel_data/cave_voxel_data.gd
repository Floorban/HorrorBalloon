extends Resource
class_name CaveVoxelData

@export var voxel_type: String = "dirt"
@export var tool_type: String = "pickaxe"
@export var texture_index: int = 0
@export var base_hp: int = 1

@export var min_height: float
@export var max_height: float

@export var neighbors: Array[CaveVoxelData] = []
@export var ores: Dictionary = {}

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
