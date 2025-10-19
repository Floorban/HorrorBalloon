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
@export var ores: Array[OreData]

func get_random_neighbor() -> int:
	var total_weight = 0.0
	for weight in neighbor_chances.values():
		total_weight += weight

	if total_weight <= 0.0:
		return texture_index

	var r = randf() * total_weight
	for neighbor_index in neighbor_chances.keys():
		r -= neighbor_chances[neighbor_index]
		if r <= 0:
			return neighbor_index

	return texture_index  # neibor is self is no neibors

func get_random_ore() -> OreData:
	if ores.size() <= 0:
		return null
	var ore = ores.pick_random()
	return ore

func spawn_ore(parent: Node3D) -> void:
	var ro = get_random_ore()
	if ro == null:
		return
	var o = ro.get_random_scene().instantiate()
	parent.add_child(o)