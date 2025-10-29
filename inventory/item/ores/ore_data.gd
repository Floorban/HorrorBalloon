extends Resource
class_name OreData

@export var ore_scenes : Array[PackedScene] = []
@export var ore_type : CaveConstants.ORE_TYPE
@export var weight : float
@export var value : int
@export var hardness : int

@export var height_curve: Curve
@export var distribution_curve: Curve 

func get_random_scene () -> PackedScene:
	if ore_scenes.is_empty():
		return
	var ps: PackedScene = ore_scenes.pick_random()
	return ps

func get_spawn_chance(depth: float, dist_to_center: float) -> float:
	var h_val = height_curve.sample(clamp(abs(depth / CaveConstants.CAVE_BOTTOM - CaveConstants.CAVE_TOP), 0.0, 1.0))
	var d_val = distribution_curve.sample(clamp(dist_to_center / CaveConstants.CAVE_MIN_WIDTH, 0.0, 1.0))
	return h_val * d_val * weight
