extends Resource
class_name CaveVoxelData

@export var voxel_type: String = "dirt"
@export var texture_index: int = 0
@export var neighbors: Array[CaveVoxelData] = []
@export var min_height: float
@export var max_height: float

@export var base_hp: float = 10.0
@export var ores: Dictionary = {}

var current_hp: float = 0.0

func _init():
	current_hp = base_hp

func get_hp() -> float:
	return current_hp

func set_hp(value: float) -> void:
	current_hp = max(value, 0.0)

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
