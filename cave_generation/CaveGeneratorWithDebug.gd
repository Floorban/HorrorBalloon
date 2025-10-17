extends Node3D

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

func _ready() -> void:
	setup()
	if show_walker and current_walker:
		current_walker.show()
	await get_tree().physics_frame
	random_walk()

func setup():
	current_walker = walkers[0]
	current_walker.global_position = global_position

func finish_walk():
	random_walk_positions.clear()
	current_walker_index += 1
	if current_walker_index < walkers.size():
		current_walker = walkers[current_walker_index]
	# else:
	# 	current_walker_index = 0
	# 	current_walker = walkers[current_walker_index]
		random_walk()

func random_walk():
	if not current_walker:
		return
	for i in range(current_walker.random_walk_length):
		
		# Move the random walker to the new position:
		current_walker.global_position += get_random_direction()
		
		current_walker.global_position.y = clampf(current_walker.global_position.y, -1000, voxel_terrain.generator.height - ceiling_thickness_m)
		
		# Only store half the random walk positions
		if i % 2 == 0:
			random_walk_positions.append(current_walker.global_position)
		
		if current_walker.display_speed > 0:
			await get_tree().create_timer(current_walker.display_speed).timeout
		
		# Carve out a chunk
		do_sphere_removal()
		
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

# Removal size returns the removal size with a small randomization
# Currently that is removal size =- removal_size * 0.25
func get_removal_size(variance : float = 1):
	var removal_size : float = current_walker.removal_size
	return removal_size + randf_range(-removal_size * variance, removal_size * variance)

#func do_sphere_smoothing():
	#voxel_tool.mode = VoxelTool.MODE_REMOVE
	#
	#voxel_tool.smooth_sphere($CurrentWalker.global_position, removal_size * 2, 2)

func get_random_wall_point():
	
	var raycast_result : VoxelRaycastResult = voxel_tool.raycast(current_walker.global_position, get_random_direction(true), 20)

	if raycast_result:
		return raycast_result.position
	else:
		return null
	
func do_sphere_removal():
	voxel_tool.mode = VoxelTool.MODE_REMOVE
	voxel_tool.do_sphere(current_walker.global_position, get_removal_size())

func do_sphere_addition(at_point : bool = false, global_point : Vector3 = Vector3.ZERO):
	voxel_tool.mode = VoxelTool.MODE_ADD
	
	if at_point:
		voxel_tool.do_sphere(global_point, get_removal_size(2) / 2)
	else:
		voxel_tool.do_sphere(current_walker.global_position, get_removal_size(2) / 2)

#func add_hard_surface():
	#voxel_tool.mode = VoxelTool.MODE_ADD
#
	#var box_removal_vector : Vector3i = Vector3i(get_removal_size(), get_removal_size(), get_removal_size())
	#
	#$BoxEndHelper.global_position = Vector3i($CurrentWalker.global_position) + box_removal_vector
	#
	#voxel_tool.do_box($CurrentWalker.global_position, Vector3i($CurrentWalker.global_position) + box_removal_vector)

#func do_box_removal():
	#voxel_tool.mode = VoxelTool.MODE_REMOVE
	#
	#var box_removal_vector : Vector3i = Vector3i(get_removal_size(), get_removal_size(), get_removal_size())
	#
	#$BoxEndHelper.global_position = Vector3i($CurrentWalker.global_position) + box_removal_vector * 3
	#
	#voxel_tool.do_box($CurrentWalker.global_position, Vector3i($CurrentWalker.global_position) + box_removal_vector)


func get_random_direction(use_float : bool = true):
	
	var direction_vector : Vector3
	
	# Omniderectional with float
	if use_float:
		direction_vector = current_walker.get_walker_range()
	else:
		# 9 directions with int
		direction_vector = Vector3([-1,0,1].pick_random(),[-1,0,1].pick_random(),[-1,0,1].pick_random())
	
	# var vector_with_magnitude : Vector3 = direction_vector * current_walker.removal_size
	
	return direction_vector
