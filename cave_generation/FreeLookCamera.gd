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

@export var voxel_terrain : VoxelTerrain
@onready var voxel_tool : VoxelTool = voxel_terrain.get_voxel_tool()
@export var cave_gen : CaveGenerator
@onready var dig_cast : RayCast3D = $DigCast

func world_to_voxel(world_pos: Vector3) -> Vector3:
	var local_pos = voxel_terrain.to_local(world_pos)
	return Vector3(local_pos.x, local_pos.y, local_pos.z)

func get_nearby_voxel_data(voxel_pos: Vector3i) -> CaveVoxelData:
	for offset in [
		Vector3i(1, 0, 0), Vector3i(-1, 0, 0),
		Vector3i(0, 1, 0), Vector3i(0, -1, 0),
		Vector3i(0, 0, 1), Vector3i(0, 0, -1)]:
		var neighbor_meta = voxel_tool.get_voxel_metadata(voxel_pos + offset)
		if neighbor_meta != null and neighbor_meta.has("type"):
			return neighbor_meta["type"]
	return null

func mine_voxel(hit_position: Vector3, radius: float, damage: float):
	var int_radius = ceil(radius)
	var center_voxel: Vector3i = Vector3i(world_to_voxel(hit_position))
	var affected_voxels: Array = []

	for x in range(-int_radius - 5, int_radius + 6):
		for y in range(-int_radius -5, int_radius + 6):
			for z in range(-int_radius -5, int_radius + 6):
				var offset = Vector3i(x, y, z)
				if offset.length() <= radius:
					var voxel_pos = center_voxel + offset
					var voxel_meta = voxel_tool.get_voxel_metadata(voxel_pos)
					var voxel_obj: CaveVoxelData = null

					if voxel_meta != null and voxel_meta.has("type"):
						voxel_obj = voxel_meta["type"]

					if voxel_obj == null:
						var tex_hint := int(voxel_tool.texture_index)
						if tex_hint >= 0 and tex_hint < cave_gen.voxel_data.size():
							voxel_obj = cave_gen.voxel_data[tex_hint].duplicate(true)
						else:
							# if texture_index is invalid, try a nearby voxel's type
							var neighbor_data := get_nearby_voxel_data(voxel_pos)
							if neighbor_data != null:
								voxel_obj = neighbor_data.duplicate(true)
							else:
								# height-based selection from cave_gen.voxel_data
								for v in cave_gen.voxel_data:
									if voxel_pos.y >= v.min_height and voxel_pos.y <= v.max_height:
										voxel_obj = v.duplicate(true)
										break
								# final fallback to index 0
								if voxel_obj == null and cave_gen.voxel_data.size() > 0:
									voxel_obj = cave_gen.voxel_data[0].duplicate(true)

						# initialize hp and assign metadata
						if voxel_obj != null:
							voxel_obj.current_hp = voxel_obj.base_hp
							voxel_tool.set_voxel_metadata(voxel_pos, {"type": voxel_obj})

					if voxel_obj == null:
						continue

					# handle destruction
					voxel_obj.current_hp -= damage
					if voxel_obj.current_hp <= 0:
						voxel_tool.mode = VoxelTool.MODE_REMOVE
						# use world position for do_sphere calls (voxel_pos -> world)
						var world_center := voxel_terrain.to_global(Vector3(voxel_pos.x, voxel_pos.y, voxel_pos.z))
						voxel_tool.do_sphere(world_center, radius)
						voxel_tool.set_voxel_metadata(voxel_pos, null)

						# Paint the destroyed voxel area with correct texture
						voxel_tool.mode = VoxelTool.MODE_TEXTURE_PAINT
						voxel_tool.texture_index = voxel_obj.texture_index
						voxel_tool.do_sphere(world_center, radius)

						# store for neighbor propagation
						affected_voxels.append({"pos": voxel_pos, "voxel": voxel_obj})
					else:
						# Save updated hp back to metadata
						voxel_tool.set_voxel_metadata(voxel_pos, {"type": voxel_obj})
					print("picked:", voxel_obj.voxel_type, "from hint or fallback")

	# neighbor propagation
	for voxel_data_dict in affected_voxels:
		var voxel_pos: Vector3i = voxel_data_dict["pos"]
		var voxel_obj: CaveVoxelData = voxel_data_dict["voxel"]

		# paint the destroyed voxel again for safety (use world position)
		var world_center := voxel_terrain.to_global(Vector3(voxel_pos.x, voxel_pos.y, voxel_pos.z))
		voxel_tool.mode = VoxelTool.MODE_TEXTURE_PAINT
		voxel_tool.texture_index = voxel_obj.texture_index
		voxel_tool.do_sphere(world_center, radius)

		for nx in range(-2, 3):
			for ny in range(-2, 3):
				for nz in range(-2, 3):
					if nx == 0 and ny == 0 and nz == 0:
						continue
					var neighbor_pos = voxel_pos + Vector3i(nx, ny, nz)
					var neighbor_meta = voxel_tool.get_voxel_metadata(neighbor_pos)

					if neighbor_meta == null or not neighbor_meta.has("type"):
						var neighbor_voxel: CaveVoxelData = voxel_obj.get_random_neighbor().duplicate(true)
						neighbor_voxel.current_hp = neighbor_voxel.base_hp
						voxel_tool.set_voxel_metadata(neighbor_pos, {"type": neighbor_voxel})

func _input(event):
	if event.is_action_pressed("primary"):
		if dig_cast.is_colliding():
			var collision_point: Vector3 = dig_cast.get_collision_point()
			mine_voxel(collision_point, 1.2, 5.0)

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
