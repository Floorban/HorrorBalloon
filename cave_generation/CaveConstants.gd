# cave_constants.gd
extends Node
class_name CaveConstants

const CAVE_MIN_WIDTH := 20.0
const CAVE_MAX_WIDTH := 100.0
const CAVE_TOP := -5.0
const CAVE_BOTTOM := -100.0

const LAYER_RANGE : Array[Vector2] = [
	Vector2(35, 60),      # rock
	Vector2(20, 25),	  # grass
	Vector2(25, 35),	  # dirt
	Vector2(-250, -150),  # gold, dirt and rock
	Vector2(-350, -250),  # ruby, rock
	Vector2(-500, -350)   # diamond, rock and non-destructable
]

enum ORE_TYPE {
	NONE,
	ROCK,
	COPPER,
	TIN,
	IRON,
	GOLD,
	RUBY,
	DIAMOND
}

static func world_to_voxel(terrain: VoxelTerrain, world_pos: Vector3) -> Vector3:
	var local_pos = terrain.to_local(world_pos)
	return Vector3(local_pos.x, local_pos.y, local_pos.z)

static func get_nearby_voxel_positions(center: Vector3i) -> Array[Vector3i]:
	var neighbors: Array[Vector3i] = []
	for nx in range(-1, 2):
		for ny in range(-1, 2):
			for nz in range(-1, 2):
				if nx == 0 and ny == 0 and nz == 0:
					continue
				var neighbor_pos: Vector3i = center + Vector3i(nx, ny, nz)
				neighbors.append(neighbor_pos)
	return neighbors

static func get_ore_type_at(depth: float, dist_to_center: float) -> ORE_TYPE:
	# Higher depth = rarer ores
	if depth > -500:
		if randf() < 0.005 and depth < -400:
			return ORE_TYPE.DIAMOND
		elif randf() < 0.01 and depth < -300:
			return ORE_TYPE.RUBY
		elif randf() < 0.02 and depth < -200:
			return ORE_TYPE.GOLD
		elif randf() < 0.04 and depth < -100:
			return ORE_TYPE.IRON
		elif randf() < 0.08 and depth < -50:
			return ORE_TYPE.TIN
		elif randf() < 0.1 and depth < -25:
			return ORE_TYPE.COPPER

	if dist_to_center > CAVE_MIN_WIDTH * 0.9:
		return ORE_TYPE.ROCK

	return ORE_TYPE.NONE
