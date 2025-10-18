# cave_constants.gd
extends Node
class_name CaveConstants

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
				var neighbor_pos = center + Vector3i(nx, ny, nz)
				neighbors.append(neighbor_pos)
	return neighbors