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

func get_nearby_voxel_data(voxel_pos: Vector3i) -> CaveVoxelData:
	for offset in [
		Vector3i(1, 0, 0), Vector3i(-1, 0, 0),
		Vector3i(0, 1, 0), Vector3i(0, -1, 0),
		Vector3i(0, 0, 1), Vector3i(0, 0, -1)]:
		var neighbor_meta = voxel_tool.get_voxel_metadata(voxel_pos + offset)
		if neighbor_meta != null and neighbor_meta.has("type"):
			return neighbor_meta["type"]
	return null

func mine_voxel(world_pos: Vector3, radius: float):
	var voxel_pos: Vector3i = Vector3i(CaveConstants.world_to_voxel(voxel_terrain,world_pos))
	var meta = voxel_tool.get_voxel_metadata(voxel_pos)

	var meta_byte: int = 0
	if meta != null and meta.has("meta"):
		meta_byte = meta["meta"]

	var texture_id = CaveConstants.decode_texture(meta_byte)
	var damage_state = CaveConstants.decode_damage(meta_byte)

	damage_state = min(damage_state + 1, 2)

	if damage_state >= 2:
		# fully destroyed
		voxel_tool.mode = VoxelTool.MODE_REMOVE
		voxel_tool.do_sphere(world_pos, radius)
		voxel_tool.set_voxel_metadata(voxel_pos, null)
	else:
		# just cracked, update meta and repaint
		meta_byte = CaveConstants.encode_meta(texture_id, damage_state)
		voxel_tool.set_voxel_metadata(voxel_pos, {"meta": meta_byte})

		voxel_tool.mode = VoxelTool.MODE_TEXTURE_PAINT
		voxel_tool.texture_index = texture_id
		voxel_tool.do_sphere(world_pos, radius * 0.8)

func debug_voxel_meta(world_pos: Vector3):
	var voxel_pos = Vector3i(CaveConstants.world_to_voxel(voxel_terrain,world_pos))
	var voxel = voxel_tool.get_voxel(voxel_pos)
	var meta = voxel_tool.get_voxel_metadata(voxel_pos)
	print("Checking voxel:", voxel_pos, " -> Voxel:", voxel, " Meta:", meta)

	if meta == null:
		print("No metadata at ", voxel_pos)
		return

	if meta.has("meta"):
		var meta_byte = meta["meta"]
		print("Voxel ", voxel_pos, 
			  " → Texture:", CaveConstants.decode_texture(meta_byte),
			  " Damage:", CaveConstants.decode_damage(meta_byte),
			  " Flags:", CaveConstants.decode_flags(meta_byte))
	else:
		print("Metadata exists but missing 'meta' key:", meta)

func _input(event):
	if event.is_action_pressed("primary"):
		if dig_cast.is_colliding():
			var collision_point: Vector3 = dig_cast.get_collision_point()
			debug_voxel_meta(collision_point)
			# mine_voxel(collision_point, 1.2)

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
