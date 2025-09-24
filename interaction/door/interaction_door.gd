extends InteractionComponent
class_name InteractionDoor

@export_category("Door Settings")
# Door Variables
var door_angle: float = 0.0
var door_velocity: float = 0.0
@export var door_smoothing: float = 80.0
var door_input_active: bool = false
var is_front: bool
var door_opened: bool = false
var door_creak_velocity_threshold: float = 0.002 # how fast the player has to open the door for the sound to play
var shut_angle_threshold: float = 0.2            # how far the door is opened to count as "opened"
var shut_snap_range: float = 0.05                # how close to starting_rotation counts as "closed"
var creak_volume_scale: float = 1000.0           # how fast we get to max volume
var door_fade_speed: float = 1.0                 # how fast sound fades in/out
var prev_door_angle: float = 0.0                 # angle of the door on the previous frame
@export var is_locked: bool = false
var was_just_unlocked: bool = false

func _ready():
	super._ready()
	starting_rotation = pivot_point.rotation.y
	maximum_rotation = deg_to_rad(rad_to_deg(starting_rotation)+maximum_rotation)
	# nodes_to_affect.append(get_tree().get_first_node_in_group("balloon").oven)

func _process(delta):
	if was_just_unlocked:
		door_velocity = 0.0
		door_input_active = false
		door_angle = starting_rotation
		pivot_point.rotation.y = starting_rotation
		was_just_unlocked = false
	else:
		if not door_input_active:
			door_velocity = lerp(door_velocity, 0.0, delta * 4.0)
		
		door_angle += door_velocity
		
		if is_locked:
			var lock_wiggle: float = 0.02
			door_angle = clamp(door_angle, starting_rotation, starting_rotation+lock_wiggle)
			pivot_point.rotation.y = door_angle
			
			if door_input_active and tertiary_se and not tertiary_audio_player.playing and not prev_door_angle == door_angle:
				tertiary_audio_player.play()
				door_input_active = false
		else:
			door_angle = clamp(door_angle, starting_rotation, maximum_rotation)
			pivot_point.rotation.y = door_angle
			door_input_active = false

			if prev_door_angle == door_angle:
				stop_door_sounds(delta)
			else:
				update_door_sounds(delta)
			
		prev_door_angle = door_angle

func _input(event):
	if not is_interacting: return

	if event is InputEventMouseMotion:
		door_input_active = true
		var delta: float = -event.relative.y * 0.003
		if not is_front:
			delta = -delta
		# Simulate resistance to small motions
		if abs(delta) < 0.01:
			delta *= 0.25
		# Smooth velocity blending
		door_velocity = lerp(door_velocity, delta, 1.0 / door_smoothing)

func interact() -> void:
	super.interact()
	lock_camera = true

## True if player is looking at the front of an object, false otherwise
func set_direction(_normal: Vector3) -> void:
	if _normal.z > 0:
		is_front = true
	else:
		is_front = false

func unlock() -> void:
	is_locked = false
	was_just_unlocked = true
	
	door_velocity = 0.0
	door_input_active = false
	door_angle = starting_rotation
	pivot_point.rotation.y = starting_rotation

## Fires when the player is interacting with a door
func update_door_sounds(delta: float) -> void:
	# Get the velocity of the door movement in this given frame.
	# The volume should be relative to how fast/slow the playeris moving the door
	var velocity_amount: float = abs(door_velocity)
	var target_volume: float = 0.0

	# Only set target volume if we pass the threshold
	if velocity_amount > door_creak_velocity_threshold and door_opened:
		target_volume = clamp((velocity_amount - door_creak_velocity_threshold) * creak_volume_scale, 0.0, 1.0)

	# Start playing if not already
	if not primary_audio_player.playing and primary_se and target_volume > 0.0:
		primary_audio_player.volume_db = -15.0  # start silent
		primary_audio_player.play()
		print("PLAY")

	# Smooth fade towards target volume (even if target is 0 → fade out)
	if primary_audio_player.playing:
		var current_vol = db_to_linear(primary_audio_player.volume_db)
		var new_vol = lerp(current_vol, target_volume, delta * door_fade_speed)
		primary_audio_player.volume_db = linear_to_db(clamp(new_vol, 0.0, 3.0))

	# SHUT LOGIC
	# Check if the player opened the door.
	if abs(door_angle - starting_rotation) > shut_angle_threshold:
		door_opened = true
	
	# If the door was previosuly opened and the player is now shutting it
	if door_opened and abs(door_angle - starting_rotation) < shut_snap_range:
		if secondary_se:
			secondary_audio_player.volume_db = -8.0
			secondary_audio_player.play()
			primary_audio_player.stop()
			print("stop!")
		door_opened = false
		notify_nodes(0)

func stop_door_sounds(delta: float) -> void:
	if not primary_audio_player: return
	if primary_audio_player.playing:
		var current_vol = db_to_linear(primary_audio_player.volume_db)
		var new_vol = lerp(current_vol, 0.0, delta * door_fade_speed)
		primary_audio_player.volume_db = linear_to_db(clamp(new_vol, 0.0, 1.0))

		# Stop completely once inaudible
		if new_vol < 0.001:
			primary_audio_player.stop()
