extends CharacterBody3D
class_name PlayerController

signal player_fall

@onready var head: Node3D = %Head
@onready var eyes: Node3D = %Eyes
@onready var player_camera: Camera3D = %Camera3D
@onready var standing_collision_shape: CollisionShape3D = $StandingCollisionShape
@onready var crouching_collision_shape: CollisionShape3D = $CrouchingCollisionShape
@onready var standup_check: RayCast3D = $StandupCheck
@onready var interaction_controller: InteractionController = %InteractionController

# Audio Settings
@export var SFX_StepR: String
@export var SFX_StepL: String
@export var SFX_Crouch: String
var step_volume: float
var step_is_playing: bool = false
var is_crouching: bool = false
var is_standing: bool = false

# Player Settings
var is_dead := false
var base_head_y : float
var base_fov: float = 90.0
var normal_sensitivity: float = 0.2
var current_sensitivity: float = normal_sensitivity
var sensitivity_restore_speed: float = 4.0
var sensitivity_fading_in: bool = false
var viewing_yaw_origin: float = 0.0

# State Machine
enum PlayerState {
	IDLE_STAND,
	IDLE_CROUCH,
	CROUCHING,
	WALKING,
	SPRINTING,
	AIR,
	VIEWING
	}
var player_state: PlayerState = PlayerState.IDLE_STAND

# Movement Variables
const walking_speed: float = 2.0
const sprinting_speed: float = 3.0
const crouching_speed: float = 1.0
const crouching_depth: float = -0.7
var can_move := true
var current_speed: float
var max_speed: float
var acceleration := 3.0
var hold_back_speed := 0.0
var moving: bool = false
var input_dir: Vector2 = Vector2.ZERO
var direction: Vector3 = Vector3.ZERO
var lerp_speed: float = 4.0
var mouse_input: Vector2
var is_in_air: bool = false

# Headbobbing Vars
const head_bobbing_sprinting_speed: float = 14.0
const head_bobbing_walking_speed: float = 10.0
const head_bobbing_crouching_speed: float = 8.0
const head_bobbing_sprinting_intensity: float = 0.2
const head_bobbing_walking_intensity: float = 0.1
const head_bobbing_crouching_intensity: float = 0.05
var head_bobbing_current_intensity: float = 0.0
var head_bobbing_vector: Vector2 = Vector2.ZERO
var head_bobbing_index: float = 0.0
var last_bob_position_x: float = 0.0
var last_bob_direction: int = 0   #movement direction of the bob (-1 = left, +1 = right)

# Camera Shake
var decay: = 0.8
var max_offset: = Vector3(0.5, 0.5, 0.5)
var max_rotation: = Vector3(1.0, 1.0, 1.0) # degrees
var trauma: = 0.0
var trauma_power: = 2
var cam_original_position: Vector3
var cam_original_rotation: Vector3

# Feet Push
var player_weight := 10.0
var feet_push_obj_strength := 20.0
@onready var push_shape_cast: ShapeCast3D = %FeetPushShapeCast

# Viewing Vars
var viewing_offet: Vector3 = Vector3(0, 5.0, -0.5)
var viewing_zoom: float = 0.8

@export var voxel_terrain : VoxelTerrain
@onready var voxel_tool : VoxelTool = voxel_terrain.get_voxel_tool()
@export var crack_decal : PackedScene

func player_init() -> void:
	cam_original_position = player_camera.position
	cam_original_rotation = player_camera.rotation_degrees
	base_head_y = head.position.y

func _ready() -> void:
	player_init()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion:
		if current_sensitivity > 0.01 and not interaction_controller.is_cam_locked():
			mouse_input = event.relative
			rotate_y(deg_to_rad(-mouse_input.x * current_sensitivity))
			head.rotate_x(deg_to_rad(-mouse_input.y * current_sensitivity))
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-85), deg_to_rad(85))
	
	if event.is_action_pressed("primary"):
		mine_voxel(interaction_controller.hand.global_position, 1.2, 5.0)
	elif event.is_action_pressed("secondary"):
		voxel_tool.mode = VoxelTool.MODE_ADD
		voxel_tool.grow_sphere(interaction_controller.hand.global_position, 1.0, 1.0)

		voxel_tool.mode = VoxelTool.MODE_TEXTURE_PAINT
		voxel_tool.do_sphere(interaction_controller.hand.global_position, 2.5)
	elif event.is_action_pressed("ui_accept"):
		voxel_tool.texture_index = posmod(voxel_tool.texture_index + 1, 3)
		print("Texture Index: %s" % str(voxel_tool.texture_index))

func world_to_voxel(world_pos: Vector3) -> Vector3:
	var local_pos = voxel_terrain.to_local(world_pos)
	return Vector3(local_pos.x, local_pos.y, local_pos.z)

func mine_voxel(_position: Vector3, radius: float, damage: float):
	var voxel_pos = world_to_voxel(_position)
	var current_hp = voxel_tool.get_voxel_metadata(voxel_pos)

	if current_hp == null:
		current_hp = 10.0

	current_hp -= damage

	var decal_instance = crack_decal.instantiate()
	voxel_terrain.add_child(decal_instance)
	decal_instance.visible = false

	if current_hp <= 0:
		# decal_instance.queue_free()
		voxel_tool.mode = VoxelTool.MODE_REMOVE
		voxel_tool.do_sphere(_position, radius)
		voxel_tool.mode = VoxelTool.MODE_TEXTURE_PAINT
		var indx = voxel_tool.texture_index
		voxel_tool.texture_index = indx + 1 if indx < 2 else 0
		voxel_tool.do_sphere(_position, radius * 2)
		voxel_tool.set_voxel_metadata(voxel_pos, null)
		print("Voxel destroyed")
	else:
		decal_instance.visible = true
		decal_instance.global_position = _position
		# voxel_tool.mode = VoxelTool.MODE_REMOVE
		# voxel_tool.mode = VoxelTool.MODE_TEXTURE_PAINT
		# voxel_tool.texture_index = 1
		# voxel_tool.do_sphere(_position, radius * 1.5)
		voxel_tool.set_voxel_metadata(voxel_pos, current_hp)
		print("Voxel HP: %s" % str(current_hp))

func get_movement_dir() -> Vector3:
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	return (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func get_local_movement_dir() -> Vector3:
	return get_movement_dir().rotated(Vector3.UP, -rotation.y)

# Falling
func update_player_verticle(delta: float) -> void:
	if not is_on_floor():
		is_in_air = true
		if velocity.y >= 0:
			velocity += get_gravity() * delta
		else: # falling down
			velocity += get_gravity() * delta * 2.0
			if velocity.y <= -20.0:
				player_fall.emit()
	else:
		if is_in_air == true: # the first frame since landing.
			# footsteps_se.play()
			# TODO: add a slow down + (camera) landing effect
			is_in_air = false

# Movement Logic
func update_player_horizontal(delta: float) -> void:
	direction = lerp(direction, get_movement_dir(), delta * 10.0)
	if direction.length() > 0.01:
		# Accelerate towards max speed
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, 0, current_speed)
	
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed * 0.8

func _physics_process(delta: float) -> void:
	if is_dead: return
	update_player_state()
	update_cam_movement(delta)
	update_player_verticle(delta)
	update_player_horizontal(delta)
	#apply_push_forces(push_shape_cast)
	move_and_slide()

func update_cam_state(delta: float) -> void:
	if is_dead: return
	# slowly bring sensitivity back to normal levels when just unlocked camera
	if sensitivity_fading_in:
		current_sensitivity = lerp(current_sensitivity, normal_sensitivity, delta * sensitivity_restore_speed)
		if abs(current_sensitivity - normal_sensitivity) < 0.01:
			current_sensitivity = normal_sensitivity
			sensitivity_fading_in = false
			
	lock_player_camera(interaction_controller.is_cam_locked())

func updatecam_shake(delta: float) -> void:
	if trauma > 0.0:
		trauma = max(trauma - decay * delta, 0.0)
		cam_shake()
	else:
		player_camera.position = cam_original_position
		player_camera.rotation_degrees = cam_original_rotation

func cam_shake() -> void:
	var amount = pow(trauma, trauma_power)
	var _offset = Vector3(
		max_offset.x * amount * randf_range(-1.0, 1.0),
		max_offset.y * amount * randf_range(-1.0, 1.0),
		max_offset.z * amount * randf_range(-1.0, 1.0)
	)
	var _rotation = Vector3(
		max_rotation.x * amount * randf_range(-1.0, 1.0),
		max_rotation.y * amount * randf_range(-1.0, 1.0),
		max_rotation.z * amount * randf_range(-1.0, 1.0)
	)
	
	player_camera.position = cam_original_position + _offset
	player_camera.rotation_degrees = cam_original_rotation + _rotation

func _process(delta: float) -> void:
	updatecam_shake(delta)
	update_cam_state(delta)

func update_player_state() -> void:
	moving = (input_dir != Vector2.ZERO)
	if not is_on_floor():
		player_state = PlayerState.AIR
	else:
		if Input.is_action_pressed("crouch"):
			if not moving:
				player_state = PlayerState.IDLE_CROUCH
			else:
				player_state = PlayerState.CROUCHING
		elif !standup_check.is_colliding() and player_state != PlayerState.VIEWING:
			if not moving:
				player_state = PlayerState.IDLE_STAND
			elif Input.is_action_pressed("sprint"):
				player_state = PlayerState.SPRINTING
			else:
				player_state = PlayerState.WALKING

		if Input.is_action_just_pressed("crouch"): play_crouch_sound("crouch")
		if Input.is_action_just_released("crouch"): play_crouch_sound("stand")

	update_player_collision(player_state)
	update_player_speed(player_state)
	updatePlayerSound(player_state)

func update_player_collision(_player_state: PlayerState) -> void:
	if _player_state == PlayerState.CROUCHING or _player_state == PlayerState.IDLE_CROUCH:
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
	else:
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true

func update_player_speed(_player_state: PlayerState) -> void:
	if not can_move: 
		current_speed = 0
		max_speed = 0
		return
	if _player_state == PlayerState.CROUCHING or _player_state == PlayerState.IDLE_CROUCH:
		# current_speed = crouching_speed
		max_speed = crouching_speed + hold_back_speed
	elif _player_state == PlayerState.WALKING:
		# current_speed = walking_speed
		max_speed = walking_speed + hold_back_speed
	elif _player_state == PlayerState.SPRINTING:
		# current_speed = sprinting_speed
		max_speed = sprinting_speed + hold_back_speed

func update_cam_movement(delta: float) -> void:
	if player_state == PlayerState.AIR:
		pass
		
	if player_state == PlayerState.CROUCHING or player_state == PlayerState.IDLE_CROUCH:
		head.position.y = lerp(head.position.y, base_head_y + crouching_depth, delta*lerp_speed)
		player_camera.fov = lerp(player_camera.fov, base_fov*0.95, delta*lerp_speed)
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed * delta
	elif player_state == PlayerState.IDLE_STAND:
		can_move = true
		eyes.position.z = lerp(eyes.position.y, 0.0, delta*lerp_speed/2.0)
		head.position.y = lerp(head.position.y, base_head_y, delta*lerp_speed)
		player_camera.fov = lerp(player_camera.fov, base_fov, delta*lerp_speed)
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed * delta
	elif player_state == PlayerState.WALKING:
		head.position.y = lerp(head.position.y, base_head_y, delta*lerp_speed)
		player_camera.fov = lerp(player_camera.fov, base_fov, delta*lerp_speed)
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed * delta
	elif player_state == PlayerState.SPRINTING:
		head.position.y = lerp(head.position.y, base_head_y, delta*lerp_speed)
		player_camera.fov = lerp(player_camera.fov, base_fov*1.05, delta*lerp_speed)
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed * delta
	elif player_state == PlayerState.VIEWING:
		#can_move = false
		current_sensitivity = current_sensitivity / 2.0
		
		var relative_yaw = rotation_degrees.y - viewing_yaw_origin
		relative_yaw = fposmod(relative_yaw + 180.0, 360.0) - 180.0
		relative_yaw = clamp(relative_yaw, -50.0, 50.0)
		rotation_degrees.y = viewing_yaw_origin + relative_yaw
		
		eyes.position.y = lerp(eyes.position.y, viewing_offet.y, delta*lerp_speed/4.0)
		eyes.position.z = lerp(eyes.position.z, viewing_offet.z, delta*lerp_speed/4.0)
		player_camera.fov = lerp(player_camera.fov, base_fov * viewing_zoom, delta*lerp_speed/2.0)
		
	head_bobbing_vector.y = sin(head_bobbing_index)
	head_bobbing_vector.x = (sin(head_bobbing_index/2.0))
	if moving:
		eyes.position.y = lerp(eyes.position.y , head_bobbing_vector.y*(head_bobbing_current_intensity/2.0),delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x , head_bobbing_vector.x*(head_bobbing_current_intensity),delta*lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y , 0.0 ,delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x , 0.0 ,delta*lerp_speed)

func lock_player_camera(locked: bool) -> void:
	if locked:
		current_sensitivity = 0.0
		sensitivity_fading_in = false
	else:
		sensitivity_fading_in = true

func apply_player_camera_sway(tilt: Vector3):
	var sway = Vector3(-tilt.x * 0.25, 0.0, -tilt.z * 0.25)
	player_camera.rotation = player_camera.rotation.lerp(sway, 0.1)

func set_viewing_mode(target_offset : Vector3 = Vector3(0, 5.0, -0.5), target_zoom : float = 0.8) -> void:
	viewing_offet = target_offset
	viewing_zoom = target_zoom
	if not is_on_floor(): return
	if player_state != PlayerState.VIEWING:
		viewing_yaw_origin = rotation_degrees.y
		player_state = PlayerState.VIEWING
		can_move = false
	else:
		player_state = PlayerState.IDLE_STAND
		can_move = true

#Push small objects around feet
func apply_push_forces(push_shape: ShapeCast3D):
	push_shape.target_position = get_local_movement_dir() * 0.15
	for i in push_shape.get_collision_count():
		var collider = push_shape.get_collider(i)
		if collider is RigidBody3D:
			var mass_ratio : float = collider.mass / player_weight
			mass_ratio = max(0.5, mass_ratio)

			var push_dir : Vector3 = (collider.global_position - global_position).normalized()
			var push_strength : float = max(velocity.length(), feet_push_obj_strength) / mass_ratio
			var push_force : Vector3 = Vector3((push_dir * push_strength).x, 0.0, (push_dir * push_strength).z)
			
			var col_contact : Vector3 = push_shape.get_collision_point(i) - collider.global_position
			collider.apply_force(push_force, col_contact)

func play_death_animation(target_pos: Vector3) -> void:
	is_dead = true
	
	global_position = (target_pos + Vector3(-3, 2, 0))
	rotation = Vector3(0,deg_to_rad(-100),0)
	player_camera.rotation = Vector3.ZERO
	lock_player_camera(true)

func updatePlayerSound(_player_state: PlayerState) -> void:
	match _player_state:
		PlayerState.IDLE_STAND, PlayerState.IDLE_CROUCH, PlayerState.CROUCHING, PlayerState.AIR, PlayerState.VIEWING:
			step_volume = lerp(step_volume, 0.0, 0.1)
			return
	
	var step_gap: float
	
	# for specific sound stuff
	match _player_state:
		PlayerState.WALKING: 
			step_gap = 0.5
			step_volume = 0.5
		PlayerState.SPRINTING: 
			step_gap = 0.35
			step_volume = 1

	if step_is_playing: return
	step_is_playing = true
	
	Audio.play(SFX_StepR, global_transform, "volume", step_volume)
	await get_tree().create_timer(step_gap).timeout

	Audio.play(SFX_StepL, global_transform, "volume", step_volume)
	await get_tree().create_timer(step_gap).timeout
	step_is_playing = false

func play_crouch_sound(stance: String):
	if is_crouching: return
	is_crouching = true
	Audio.play(SFX_Crouch, global_transform, "stance", stance)
	await get_tree().create_timer(0.3).timeout
	is_crouching = false
