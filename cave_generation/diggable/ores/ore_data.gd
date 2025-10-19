extends Resource
class_name OreData

@export var ore_scenes : Array[PackedScene] = []
@export var ore_type : CaveConstants.ORE_TYPE
@export var weight : float
@export var value : int

func get_random_scene () -> PackedScene:
	if ore_scenes.is_empty():
		return
	var ps: PackedScene = ore_scenes.pick_random()
	return ps
