extends RigidBody3D
class_name OreInstance

@onready var voxel_terrain : Voxel = get_tree().get_first_node_in_group("terrain")
@onready var voxel_tool : VoxelTool = voxel_terrain.get_voxel_tool()

var mine_times : int = 3
var voxel_pos: Vector3
var is_falling := false

func _ready() -> void:
	freeze = true
	if voxel_terrain.has_signal("voxel_removed"):
		voxel_terrain.connect("voxel_removed", Callable(self, "_on_voxel_removed"))

func _on_voxel_removed(removed_pos: Vector3) -> void:
	voxel_pos = CaveConstants.world_to_voxel(voxel_terrain, global_position)
	if is_falling:
		return
	if voxel_pos.distance_to(removed_pos) > 1.0:
		return

	# var below_pos = voxel_pos + Vector3(0, -1, 0)
	# if _is_supported(below_pos):
	# 	print("s", voxel_pos.distance_to(removed_pos))
	# 	return

	mine_times -= 1
	if mine_times <= 0:
		start_falling()

func _is_supported(check_pos: Vector3) -> bool:
	if voxel_tool.get_voxel(check_pos) != 0:
		return true

	var neighbors = [
		check_pos + Vector3(1, 0, 0),
		check_pos + Vector3(-1, 0, 0),
		check_pos + Vector3(0, 0, 1),
		check_pos + Vector3(0, 0, -1)
	]

	for n in neighbors:
		if voxel_tool.get_voxel(n) != 0:
			return true
	return false

func start_falling():
	print("Ore at ", voxel_pos, " lost support — falling.")
	is_falling = true
	freeze = false

func init_ore_data(times_to_hit : int):
	mine_times = times_to_hit
