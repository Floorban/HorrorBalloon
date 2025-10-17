extends Node3D
class_name CaveGenerator

@export var voxel_data: Array[CaveVoxelData] = []
@export var voxel_terrain : VoxelTerrain
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
		paint_textures_by_height()
	random_walk_positions.clear()

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
	voxel_tool.mode = VoxelTool.MODE_REMOVE
	voxel_tool.do_sphere(current_walker.global_position, get_removal_size())

func do_sphere_addition(at_point: bool = false, global_point: Vector3 = Vector3.ZERO):
	voxel_tool.mode = VoxelTool.MODE_ADD

	var pos: Vector3
	if at_point:
		pos = global_point
	else:
		pos = current_walker.global_position

	voxel_tool.do_sphere(pos, get_removal_size(1) / 1.5)

func paint_textures_by_height():
	voxel_tool.mode = VoxelTool.MODE_TEXTURE_PAINT

	for pos in random_walk_positions:
		# collect all voxel_data that match this height
		var matching_voxels: Array = []
		for v in voxel_data:
			if pos.y >= v.min_height and pos.y <= v.max_height:
				matching_voxels.append(v)

		# pick one randomly if multiple, otherwise fallback
		var voxel_copy: CaveVoxelData = null
		if matching_voxels.size() > 0:
			voxel_copy = matching_voxels[randi() % matching_voxels.size()]
		else:
			voxel_copy = voxel_data[0] # fallback to first element

		# paint the voxel
		voxel_tool.texture_index = voxel_copy.texture_index
		# voxel_tool.texture_opacity = 0.5
		# voxel_tool.texture_falloff = 0.4
		voxel_tool.do_sphere(pos, get_removal_size(3.0))

		# assign metadata
		var voxel_pos: Vector3i = Vector3i(world_to_voxel(pos))
		voxel_tool.set_voxel_metadata(voxel_pos, {"type": voxel_copy.duplicate(true)})

# func paint_textures_by_height():
# 	voxel_tool.mode = VoxelTool.MODE_TEXTURE_PAINT
# 	var paint_radius := 10.0

# 	random_walk_positions.shuffle()

# 	for walk_position: Vector3 in random_walk_positions:
# 		if current_walker.display_speed > 0:
# 			await get_tree().create_timer(current_walker.display_speed).timeout

# 		current_walker.global_position = walk_position

# 		# Raycast to find the actual voxel to paint
# 		var raycast_result: VoxelRaycastResult = voxel_tool.raycast(walk_position, get_random_direction(true), 30)
# 		if raycast_result == null:
# 			continue  # skip if nothing hit

# 		var voxel_pos: Vector3i = Vector3i(world_to_voxel(raycast_result.position))
# 		var voxel_meta = voxel_tool.get_voxel_metadata(voxel_pos)
# 		var voxel_obj: CaveVoxelData = null

# 		if voxel_meta != null and voxel_meta.has("type"):
# 			voxel_obj = voxel_meta["type"]
# 		else:
# 			# pick all voxel_data matching height at the hit point
# 			var matching_voxels: Array = []
# 			for v in voxel_data:
# 				if raycast_result.position.y >= v.min_height and raycast_result.position.y <= v.max_height:
# 					matching_voxels.append(v)

# 			if matching_voxels.size() > 0:
# 				voxel_obj = matching_voxels[randi() % matching_voxels.size()]
# 			else:
# 				voxel_obj = voxel_data[0]

# 			voxel_obj = voxel_obj.duplicate(true)
# 			voxel_obj.current_hp = voxel_obj.base_hp
# 			voxel_tool.set_voxel_metadata(voxel_pos, {"type": voxel_obj})

# 		voxel_tool.mode = VoxelTool.MODE_TEXTURE_PAINT
# 		voxel_tool.texture_index = voxel_obj.texture_index
# 		# voxel_tool.texture_opacity = 1.0
# 		# voxel_tool.texture_falloff = 0.4
# 		voxel_tool.do_sphere(raycast_result.position, paint_radius)

func world_to_voxel(world_pos: Vector3) -> Vector3:
	var local_pos = voxel_terrain.to_local(world_pos)
	return Vector3(local_pos.x, local_pos.y, local_pos.z)

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
