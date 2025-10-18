# cave_constants.gd
extends Node
class_name CaveConstants

const TEXTURE_MASK   = 0b00001111  # bits 0–3
const DAMAGE_MASK    = 0b00110000  # bits 4–5
const DAMAGE_SHIFT   = 4
const FLAG_MASK      = 0b11000000  # bits 6–7

# encode texture + damage + flags into a single byte
static func encode_meta(texture_id: int, damage_state: int = 0, flags: int = 0) -> int:
	return (texture_id & 0b1111) | ((damage_state & 0b11) << DAMAGE_SHIFT) | ((flags & 0b11) << 6)

# decode each field
static func decode_texture(meta: int) -> int:
	return meta & TEXTURE_MASK

static func decode_damage(meta: int) -> int:
	return (meta & DAMAGE_MASK) >> DAMAGE_SHIFT

static func decode_flags(meta: int) -> int:
	return (meta & FLAG_MASK) >> 6

static func world_to_voxel(terrain: VoxelTerrain, world_pos: Vector3) -> Vector3:
	var local_pos = terrain.to_local(world_pos)
	return Vector3(local_pos.x, local_pos.y, local_pos.z)