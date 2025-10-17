extends Resource
class_name CaveVoxelData

@export var voxel_type: String = "dirt"
@export var texture_index: int = 0
@export var neighbors: Array[CaveVoxelData] = []
@export var min_height: float = -1000
@export var max_height: float = 1000

@export var base_hp: float = 10.0
@export var ores: Dictionary = {}

var current_hp: float = 0.0
var chance: float = 1.0  # used for weighted random selection among neighbors

func _init():
	current_hp = base_hp

func get_hp() -> float:
	return current_hp

func set_hp(value: float) -> void:
	current_hp = max(value, 0.0)

#func get_random_neighbor() -> CaveVoxelData:
	#var total = 0.0
	#for n in neighbors:
		#total += n.chance
	#var r = randf() * total
	#for n in neighbors:
		#r -= n.chance
		#if r <= 0:
			#return n
	#return neighbors[0] if neighbors.size() > 0 else self

func get_random_neighbor() -> CaveVoxelData:
	if neighbors.size() == 0:
		return self 

	var valid_neighbors: Array = []
	for n in neighbors:
		if n != null:
			valid_neighbors.append(n)

	if valid_neighbors.is_empty():
		return self

	return valid_neighbors[randi() % valid_neighbors.size()]

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
