extends CharacterBody3D
class_name PlayerController

@onready var head: Node3D = %Head
@onready var eyes: Node3D = %Eyes
@onready var player_camera: Camera3D = %Camera3D
@onready var standing_collision_shape: CollisionShape3D = $StandingCollisionShape
@onready var crouching_collision_shape: CollisionShape3D = $CrouchingCollisionShape
@onready var standup_check: RayCast3D = $StandupCheck
@onready var interaction_controller: InteractionController = %InteractionController
@onready var note_camera: Camera3D = %NoteCamera

# Note sway variables
@onready var note_hand: Marker3D = %NoteHand
@export var note_sway_amount: float = .1

# Movement Variables
const walking_speed: float = 2.0
const sprinting_speed: float = 3.0
const crouching_speed: float = 1.0
const crouching_depth: float = -0.95
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

# Player Settings
var base_head_y : float
var base_fov: float = 90.0
var normal_sensitivity: float = 0.2
var current_sensitivity: float = normal_sensitivity
var sensitivity_restore_speed: float = 4.0  # tweak for smoothness
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
var last_bob_position_x: float = 0.0                                            # Tracks the previous horizontal head-bob position
var last_bob_direction: int = 0                                                 # Tracks the previous movement direction of the bob (-1 = left, +1 = right)

var is_dead := false

# Audio Settings
var e_right_step: FmodEventEmitter3D
var e_left_step: FmodEventEmitter3D
var step_is_playing: bool = false

func _ready() -> void:
	e_right_step = get_node("Audio/RightStep")
	e_left_step = get_node("Audio/LeftStep")
	
	base_head_y = head.position.y
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion:
		if current_sensitivity > 0.01 and not interaction_controller.isCameraLocked():
			mouse_input = event.relative
			rotate_y(deg_to_rad(-mouse_input.x * current_sensitivity))
			head.rotate_x(deg_to_rad(-mouse_input.y * current_sensitivity))
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-70), deg_to_rad(70))

func _physics_process(delta: float) -> void:
	if is_dead: return
	
	updatePlayerState()
	updateCamera(delta)
	
	# Falling
	if not is_on_floor():
		is_in_air = true
		if velocity.y >= 0:
			velocity += get_gravity() * delta
		else: # falling down
			velocity += get_gravity() * delta * 2.0
	else:
		if is_in_air == true: # the first frame since landing.
			# footsteps_se.play()
			# TODO: add a slow down + (camera) landing effect
			is_in_air = false
			
	# Movement Logic
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	var target_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = lerp(direction, target_dir, delta * 10.0)

	if direction.length() > 0.01:
		# Accelerate towards max speed
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, 0, current_speed)

	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed * 0.8
			
	move_and_slide()
	note_tilt_and_sway(input_dir, delta)

func _process(delta: float) -> void:
	if is_dead: return

	# slowly bring sensitivity back to normal levels when just unlocked camera
	if sensitivity_fading_in:
		current_sensitivity = lerp(current_sensitivity, normal_sensitivity, delta * sensitivity_restore_speed)
		if abs(current_sensitivity - normal_sensitivity) < 0.01:
			current_sensitivity = normal_sensitivity
			sensitivity_fading_in = false
			
	set_camera_locked(interaction_controller.isCameraLocked())
	
func updatePlayerState() -> void:
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

	updatePlayerColShape(player_state)
	updatePlayerSpeed(player_state)
	updatePlayerSound(player_state)
	
func updatePlayerColShape(_player_state: PlayerState) -> void:
	if _player_state == PlayerState.CROUCHING or _player_state == PlayerState.IDLE_CROUCH:
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
	else:
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
	
func updatePlayerSpeed(_player_state: PlayerState) -> void:
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

func updateCamera(delta: float) -> void:
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
		can_move = false
		current_sensitivity = current_sensitivity / 2.0
		var local_rot = rotation_degrees
		# Normalize to -180 to 180 (so the cam doesn't revert to left when all the way right, vice versa)
		local_rot.y = fposmod(local_rot.y, 180.0)
		local_rot.y = clamp(local_rot.y, viewing_yaw_origin - 50.0, viewing_yaw_origin + 50.0)
		eyes.position.y = lerp(eyes.position.y, 5.0, delta*lerp_speed/4.0)
		eyes.position.z = lerp(eyes.position.z, -.5, delta*lerp_speed/4.0)
		player_camera.fov = lerp(player_camera.fov, base_fov*0.8, delta*lerp_speed/2.0)
		
	head_bobbing_vector.y = sin(head_bobbing_index)
	head_bobbing_vector.x = (sin(head_bobbing_index/2.0))
	if moving:
		eyes.position.y = lerp(eyes.position.y , head_bobbing_vector.y*(head_bobbing_current_intensity/2.0),delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x , head_bobbing_vector.x*(head_bobbing_current_intensity),delta*lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y , 0.0 ,delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x , 0.0 ,delta*lerp_speed)
	
	note_camera.fov = player_camera.fov
	
func set_camera_locked(locked: bool) -> void:
	if locked:
		current_sensitivity = 0.0
		sensitivity_fading_in = false
	else:
		sensitivity_fading_in = true

func note_tilt_and_sway(_input_dir: Vector2, delta: float) -> void:
	if note_hand:
		note_hand.rotation.z = lerp(note_hand.rotation.z, -_input_dir.x * note_sway_amount, 10 * delta)
		note_hand.rotation.x = lerp(note_hand.rotation.x, -_input_dir.y * note_sway_amount, 10 * delta)

func apply_sway(tilt: Vector3):
	var sway = Vector3(-tilt.x * 0.5, 0.0, -tilt.z * 0.5)
	player_camera.rotation = player_camera.rotation.lerp(sway, 0.1)

func set_viewing_mode() -> void:
	if not is_on_floor(): return
	if player_state != PlayerState.VIEWING:
		viewing_yaw_origin = rotation_degrees.y
		player_state = PlayerState.VIEWING
	else:
		player_state = PlayerState.IDLE_STAND

func play_death_animation(target_pos: Vector3) -> void:
	e_right_step.volume = 0
	e_left_step.volume = 0
	is_dead = true
	
	global_position = (target_pos)
	rotation = Vector3(0,deg_to_rad(-165),0)
	player_camera.rotation = Vector3.ZERO
	set_camera_locked(true)

func updatePlayerSound(_player_state: PlayerState) -> void:
	match _player_state:
		PlayerState.IDLE_STAND, PlayerState.IDLE_CROUCH, PlayerState.CROUCHING, PlayerState.AIR, PlayerState.VIEWING:
			e_right_step.volume = lerp(e_right_step.volume, 0.0, 0.1)
			e_left_step.volume = lerp(e_left_step.volume, 0.0, 0.1)
			return
	
	var step_gap: float
	
	# for specific sound stuff
	match _player_state:
		PlayerState.WALKING: 
			step_gap = 0.5
			e_right_step.volume = 0.5
			e_left_step.volume = 0.5
		PlayerState.SPRINTING: 
			step_gap = 0.35
			e_right_step.volume = 1
			e_left_step.volume = 1
	
	if step_is_playing: return
	step_is_playing = true
	
	e_right_step.play()
	print("Right step")
	await get_tree().create_timer(step_gap).timeout

	e_left_step.play()
	print("Left step")
	await get_tree().create_timer(step_gap).timeout
	step_is_playing = false

func _exit_tree():
	e_right_step.stop()
	e_left_step.stop()
	pass
