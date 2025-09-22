@tool
extends InteractionComponent
class_name InteractionWheel

# Wheel Variables
var wheel_kickback: float = 0.0
var wheel_kick_intensity: float = 0.1
var wheel_rotation: float = 0.0
var wheel_creak_velocity_threshold: float = 0.005 # how fast the player has to turn the wheel for the sound to play
var wheel_fade_speed: float = 50.0                # how fast sound fades in/out
var last_wheel_angle: float = 0.0                 # angle of the wheel on the previous frame
var wheel_kickback_triggered: bool = false        # true if the player has stopped interacting and the wheel is kicking back

func _ready() -> void:
	super._ready()
	starting_rotation = object_ref.rotation.z
	maximum_rotation = deg_to_rad(rad_to_deg(starting_rotation)+maximum_rotation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_interacting:
		update_wheel_sounds(delta)
	else:
		stop_wheel_sounds(delta)
		
	if abs(wheel_kickback) > 0.001:
		wheel_rotation += wheel_kickback
		wheel_kickback = lerp(wheel_kickback, 0.0, delta * 6.0)
		
		var min_wheel_rotation = starting_rotation / 0.1
		var max_wheel_rotation = maximum_rotation / 0.1
		wheel_rotation = clamp(wheel_rotation, min_wheel_rotation, max_wheel_rotation)
		
		object_ref.rotation.z = wheel_rotation * 0.1
		var percentage = (object_ref.rotation.z - starting_rotation) / (maximum_rotation - starting_rotation)
		notify_nodes(percentage)
		
		# Detect start of kickback (player just released the wheel)
		if not is_interacting and not wheel_kickback_triggered and abs(wheel_kickback) > 0.01:
			wheel_kickback_triggered = true

			if secondary_se:
				secondary_audio_player.stop()   # reset to avoid overlap
				secondary_audio_player.volume_db = -0.0
				secondary_audio_player.play()
	else:
		wheel_kickback_triggered = false


func preInteract(hand: Marker3D, target: Node = null) -> void:
	super.preInteract(hand, target)
	lock_camera = true
	previous_mouse_position = get_viewport().get_mouse_position()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event):
	if not is_interacting: return

	if event is InputEventMouseMotion:
		var mouse_position: Vector2 = event.position
		if calculate_cross_product(mouse_position) > 0:
			wheel_rotation += 0.1
		else:
			wheel_rotation -= 0.1
			
		object_ref.rotation.z = wheel_rotation *.1
		object_ref.rotation.z = clamp(object_ref.rotation.z, starting_rotation, maximum_rotation)
		var percentage: float = (object_ref.rotation.z - starting_rotation) / (maximum_rotation - starting_rotation)
			
		previous_mouse_position = mouse_position
		
		# Clamp internal wheel_rotation using derived limits
		var min_wheel_rotation = starting_rotation / 0.1
		var max_wheel_rotation = maximum_rotation / 0.1
		wheel_rotation = clamp(wheel_rotation, min_wheel_rotation, max_wheel_rotation)

		notify_nodes(percentage)

## Uses mouse position to determine if the player is moving their mouse in a clockwise or counter-clockwise motion
func calculate_cross_product(_mouse_position: Vector2) -> float:
	var center_position = camera.unproject_position(object_ref.global_transform.origin)
	var vector_to_previous = previous_mouse_position - center_position
	var vector_to_current = _mouse_position - center_position
	var cross_product = vector_to_current.x * vector_to_previous.y - vector_to_current.y * vector_to_previous.x
	return cross_product

func update_wheel_sounds(delta: float) -> void:
	# --- Calculate angular speed ---
	var angular_speed = abs(object_ref.rotation.z - last_wheel_angle) / max(delta, 0.0001)
	last_wheel_angle = object_ref.rotation.z

	# --- Determine target volume only if above threshold ---
	var target_volume: float = 0.0
	if angular_speed > wheel_creak_velocity_threshold:
		pass
		# target_volume = clamp((angular_speed - wheel_creak_velocity_threshold) * creak_volume_scale, 0.0, 1.0)

	# --- Start looping creak if not playing and needed ---
	if not primary_audio_player.playing and primary_se and target_volume > 0:
		primary_audio_player.volume_db = -15.0
		primary_audio_player.play()

	# --- Smooth fade in/out ---
	if primary_audio_player.playing:
		var current_vol = db_to_linear(primary_audio_player.volume_db)
		var new_vol = lerp(current_vol, target_volume, delta * wheel_fade_speed)
		primary_audio_player.volume_db = linear_to_db(clamp(new_vol, 0.0, 1.0))

		# Stop sound if it has faded out completely
		if new_vol < 0.001 and target_volume == 0.0:
			primary_audio_player.stop()

func stop_wheel_sounds(delta: float) -> void:
	if not primary_audio_player: return
	if primary_audio_player.playing:
		var current_vol = db_to_linear(primary_audio_player.volume_db)
		var new_vol = lerp(current_vol, 0.0, delta * wheel_fade_speed)
		primary_audio_player.volume_db = linear_to_db(clamp(new_vol, 0.0, 1.0))

		# Stop completely once inaudible
		if new_vol < 0.001:
			primary_audio_player.stop()

func _get_property_list() -> Array[Dictionary]:
	var ret: Array[Dictionary] = []
	ret.append({
		"name": "_maximum_rotation",
		"type": TYPE_FLOAT,
	})
	ret.append({
		"name": "nodes_to_affect",
		"type": TYPE_ARRAY,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "Node"
	})
	return ret

func _set(prop_name: StringName, val) -> bool:
	var retval := true
	match prop_name:
		"_maximum_rotation":
			maximum_rotation = val
		_:
			retval = false
	notify_property_list_changed()
	return retval

func _get(prop_name: StringName):
	match prop_name:
		"_maximum_rotation":
			return maximum_rotation
	return null