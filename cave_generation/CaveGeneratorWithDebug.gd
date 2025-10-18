extends Node3D
class_name CaveGenerator

@export var voxel_terrain : Voxel
@onready var voxel_tool : VoxelTool = voxel_terrain.get_voxel_tool()

@export var show_walker : bool = true
@export var walkers : Array[CaveWalker] = []
@onready var current_walker : CaveWalker

var current_walker_index : int = 0
@export var ceiling_thickness_m : int = 5
@export var rock_preload : PackedScene
@export var do_wall_decoration_step : bool = true
@export var do_voxel_addition : bool = true

var random_walk_positions : Array[Vector3] = []
var affected_voxels: Array[Vector3i] = []
@onready var noise := FastNoiseLite.new()

func _ready() -> void:
	setup()
	if show_walker and current_walker:
		current_walker.show()
	await get_tree().physics_frame
	random_walk()

func setup():
	current_walker = walkers[0]
	current_walker.global_position = global_position
	noise.seed = randi()
	noise.frequency = 0.03
	noise.fractal_octaves = 3

func finish_walk():
	current_walker_index += 1
	if current_walker_index < walkers.size():
		current_walker = walkers[current_walker_index]
		random_walk()
	else:
		await get_tree().process_frame
		set_voxel_meta_data()
	random_walk_positions.clear()
	affected_voxels.clear()

func random_walk():
	if not current_walker:
		return

	for i in range(current_walker.random_walk_length):
		current_walker.global_position += get_random_direction()
		current_walker.global_position.y = clampf(
			current_walker.global_position.y,
			-1000,
			voxel_terrain.generator.height - ceiling_thickness_m
		)

		if i % 2 == 0:
			random_walk_positions.append(current_walker.global_position)

		if current_walker.display_speed > 0:
			await get_tree().create_timer(current_walker.display_speed).timeout

		# Carve out a chunk
		do_sphere_removal()

		# Add rock formations or walls occasionally
		if do_voxel_addition:
			var wall_point = get_random_wall_point()
			if wall_point:
				current_walker.ray.look_at(wall_point)
				do_sphere_addition(true, wall_point)

	if do_wall_decoration_step:
		wall_additions_pass()

func wall_additions_pass():
	for walk_position : Vector3 in random_walk_positions:
		if current_walker.display_speed > 0:
			await get_tree().create_timer(current_walker.display_speed).timeout

		var raycast_result : VoxelRaycastResult = voxel_tool.raycast(walk_position, get_random_direction(true), 20)
		current_walker.global_position = walk_position

		if raycast_result and current_walker.tresure_chance > randf():
			current_walker.ray.look_at(raycast_result.position)
			var new_instance : Node3D = [rock_preload].pick_random().instantiate()
			self.add_child(new_instance)
			new_instance.global_position = raycast_result.position
			new_instance.scale = new_instance.scale * randf_range(0.5, 2.0)
			new_instance.look_at(new_instance.global_position + raycast_result.normal)

	finish_walk()

func do_sphere_removal():
	var radius = get_removal_size()
	voxel_tool.mode = VoxelTool.MODE_REMOVE
	voxel_tool.do_sphere(current_walker.global_position, radius)

	# record all voxels near the surface
	var voxel_center = Vector3i(CaveConstants.world_to_voxel(voxel_terrain, current_walker.global_position))
	var int_r = ceil(radius)
	for x in range(-int_r, int_r + 1):
		for y in range(-int_r, int_r + 1):
			for z in range(-int_r, int_r + 1):
				var voxel_pos = voxel_center + Vector3i(x, y, z)
				if Vector3(x, y, z).length() <= radius:
					if not affected_voxels.has(voxel_pos):
						affected_voxels.append(voxel_pos)

func do_sphere_addition(at_point: bool = false, global_point: Vector3 = Vector3.ZERO):
	voxel_tool.mode = VoxelTool.MODE_ADD

	var pos: Vector3
	if at_point:
		pos = global_point
	else:
		pos = current_walker.global_position

	voxel_tool.do_sphere(pos, get_removal_size(1) / 1.5)

func set_voxel_meta_data():
	if affected_voxels.is_empty():
		print("No affected voxels recorded!")
		return

	for voxel_pos in affected_voxels:
		var world_y = voxel_pos.y
		var tex_id = get_texture_for_height(world_y)
		var meta_byte = CaveConstants.encode_meta(tex_id, 0)

		voxel_tool.set_voxel_metadata(voxel_pos, {"meta": meta_byte})

func get_texture_for_height(y: float) -> int:
	for v in voxel_terrain.voxel_data:
		if y >= v.min_height and y <= v.max_height:
			return v.texture_index
	return voxel_terrain.voxel_data[0].texture_index

func get_removal_size(variance : float = 1.0) -> float:
	var removal_size : float = current_walker.removal_size
	return removal_size + randf_range(-removal_size * variance, removal_size * variance)

func get_random_wall_point() -> Vector3:
	var raycast_result : VoxelRaycastResult = voxel_tool.raycast(current_walker.global_position, get_random_direction(true), 20)
	if raycast_result:
		return raycast_result.position
	return Vector3.ZERO

func get_random_direction(use_float : bool = true) -> Vector3:
	if use_float:
		return current_walker.get_walker_range()
	return Vector3(
		[-1, 0, 1].pick_random(),
		[-1, 0, 1].pick_random(),
		[-1, 0, 1].pick_random())
