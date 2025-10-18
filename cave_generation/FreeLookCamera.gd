class_name FreeLookCamera extends Camera3D

# Modifier keys' speed multiplier
const SHIFT_MULTIPLIER = 2.5
const ALT_MULTIPLIER = 1.0 / SHIFT_MULTIPLIER

@export_range(0.0, 1.0) var sensitivity: float = 0.25

# Mouse state
var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0

# Movement state
var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 30
var _deceleration = -10
var _vel_multiplier = 4

# Keyboard state
var _w = false
var _s = false
var _a = false
var _d = false
var _q = false
var _e = false
var _shift = false
var _alt = false

@export var voxel_terrain : Voxel
@onready var voxel_tool : VoxelTool = voxel_terrain.get_voxel_tool()
@export var cave_gen : CaveGenerator
@onready var dig_cast : RayCast3D = $DigCast

func mine_voxel(world_pos: Vector3, radius: float, tool_type: String):
	var voxel_pos: Vector3i = Vector3i(CaveConstants.world_to_voxel(voxel_terrain, world_pos))
	var meta = voxel_tool.get_voxel_metadata(voxel_pos)

	var voxel_id: int = 0

	if meta != null and meta.has("id"):
		voxel_id = meta["id"]
	else:
		voxel_id = 0  # default rock

	# check id
	if voxel_id < 0 or voxel_id >= voxel_terrain.voxel_data.size():
		print("invalid voxel id:", voxel_id)
		return

	# get voxel data
	var voxel_data: CaveVoxelData = voxel_terrain.voxel_data[voxel_id]

	# check tool type
	if voxel_data.tool_type != "" and voxel_data.tool_type != tool_type:
		print("wrong tool, need:", voxel_data.tool_type)
		return

	# get current damage
	var damage: int = 0
	if meta != null and meta.has("damage"):
		damage = meta["damage"]

	damage += 1 # TODO: add tool power

	print("Mining voxel at:", voxel_pos, "ID:", voxel_id, "Texture:", voxel_data.texture_index, "Current damage:", damage, "Max HP:", voxel_data.base_hp)

	if damage >= voxel_data.base_hp:
		# fully destroyed
		voxel_tool.mode = VoxelTool.MODE_REMOVE
		voxel_tool.do_sphere(world_pos, radius)
		voxel_tool.set_voxel_metadata(voxel_pos, null)
		paint_neighbors_with_incremental(voxel_pos, radius, voxel_data, 1.2)

		# repaint and set meta data to neibours
		# var neighbor_positions = CaveConstants.get_nearby_voxel_positions(voxel_pos)
		# for n_pos in neighbor_positions:
		# 	var n_meta = voxel_tool.get_voxel_metadata(n_pos)
		# 	if n_meta == null or not n_meta.has("id"):
		# 		var new_neighbor_id = voxel_data.get_random_neighbor()
		# 		if new_neighbor_id >= 0 and new_neighbor_id < voxel_terrain.voxel_data.size():
		# 			voxel_tool.set_voxel_metadata(n_pos, {
		# 				"id": new_neighbor_id,
		# 				"pos": n_pos,
		# 				"damage": 0
		# 			})
					
		# 			var new_neighbor_voxel = voxel_terrain.voxel_data[new_neighbor_id]
		# 			voxel_tool.texture_index = new_neighbor_voxel.texture_index
		# 			voxel_tool.mode = VoxelTool.MODE_TEXTURE_PAINT
		# 			voxel_tool.texture_falloff = 0.0 
		# 			voxel_tool.do_sphere(Vector3(n_pos), radius)
	else:
		# update meta and repaint cracked voxel
		voxel_tool.set_voxel_metadata(voxel_pos, {
			"id": voxel_id,
			"pos": voxel_pos,
			"damage": damage,
			"incremental_chance": 1.2
		})

		voxel_tool.mode = VoxelTool.MODE_TEXTURE_PAINT
		voxel_tool.texture_index = voxel_data.texture_index
		voxel_tool.do_sphere(world_pos, 0.1)

func paint_neighbors_with_incremental(center_pos: Vector3i, radius: float, voxel_data: CaveVoxelData, incremental_chance: float):
	var neighbor_positions = CaveConstants.get_nearby_voxel_positions(center_pos)
	for n_pos in neighbor_positions:
		var n_meta = voxel_tool.get_voxel_metadata(n_pos)
		if n_meta == null or not n_meta.has("id"):
			var skip = false
			# check the neighbor's neighbors
			for nn_pos in CaveConstants.get_nearby_voxel_positions(n_pos):
				var nn_meta = voxel_tool.get_voxel_metadata(nn_pos)
				if nn_meta != null and nn_meta.has("id") and nn_meta["id"] == 0:
					skip = true
					break
			if skip:
				continue  # don't paint the neighbor, cuz it's default rock

			# assign new neighbor voxel
			var new_neighbor_id = voxel_data.get_random_neighbor(incremental_chance)
			if new_neighbor_id >= 0 and new_neighbor_id < voxel_terrain.voxel_data.size():
				voxel_tool.set_voxel_metadata(n_pos, {
					"id": new_neighbor_id,
					"pos": n_pos,
					"damage": 0,
					"incremental_chance": incremental_chance * 0.7  # decay for farther layers
				})

				var new_neighbor_voxel = voxel_terrain.voxel_data[new_neighbor_id]
				voxel_tool.texture_index = new_neighbor_voxel.texture_index
				voxel_tool.mode = VoxelTool.MODE_TEXTURE_PAINT
				voxel_tool.texture_falloff = 0.0 
				voxel_tool.do_sphere(Vector3(n_pos), radius)

func _input(event):
	if event.is_action_pressed("primary"):
		if dig_cast.is_colliding():
			var collision_point: Vector3 = dig_cast.get_collision_point()
			# debug_voxel_meta(collision_point)
			mine_voxel(collision_point, 1.2, "pickaxe")

	# Receives mouse motion
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
	
	# Receives mouse button input
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT: # Only allows rotation if right click down
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
			MOUSE_BUTTON_WHEEL_UP: # Increases max velocity
				_vel_multiplier = clamp(_vel_multiplier * 1.1, 0.2, 20)
			MOUSE_BUTTON_WHEEL_DOWN: # Decereases max velocity
				_vel_multiplier = clamp(_vel_multiplier / 1.1, 0.2, 20)

	# Receives key input
	if event is InputEventKey:
		match event.keycode:
			KEY_W:
				_w = event.pressed
			KEY_S:
				_s = event.pressed
			KEY_A:
				_a = event.pressed
			KEY_D:
				_d = event.pressed
			KEY_Q:
				_q = event.pressed
			KEY_E:
				_e = event.pressed
			KEY_SHIFT:
				_shift = event.pressed
			KEY_ALT:
				_alt = event.pressed

# Updates mouselook and movement every frame
func _process(delta):
	_update_mouselook()
	_update_movement(delta)

# Updates camera movement
func _update_movement(delta):
	# Computes desired direction from key states
	_direction = Vector3(
		(_d as float) - (_a as float), 
		(_e as float) - (_q as float),
		(_s as float) - (_w as float)
	)
	
	# Computes the change in velocity due to desired direction and "drag"
	# The "drag" is a constant acceleration on the camera to bring it's velocity to 0
	var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta \
		+ _velocity.normalized() * _deceleration * _vel_multiplier * delta
	
	# Compute modifiers' speed multiplier
	var speed_multi = 1
	if _shift: speed_multi *= SHIFT_MULTIPLIER
	if _alt: speed_multi *= ALT_MULTIPLIER
	
	# Checks if we should bother translating the camera
	if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared():
		# Sets the velocity to 0 to prevent jittering due to imperfect deceleration
		_velocity = Vector3.ZERO
	else:
		# Clamps speed to stay within maximum value (_vel_multiplier)
		_velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier)
		_velocity.y = clamp(_velocity.y + offset.y, -_vel_multiplier, _vel_multiplier)
		_velocity.z = clamp(_velocity.z + offset.z, -_vel_multiplier, _vel_multiplier)
	
		translate(_velocity * delta * speed_multi)

# Updates mouse look 
func _update_mouselook():
	# Only rotates mouse if the mouse is captured
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sensitivity
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		_mouse_position = Vector2(0, 0)
		
		# Prevents looking up/down too far
		pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
		_total_pitch += pitch
	
		rotate_y(deg_to_rad(-yaw))
		rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))
