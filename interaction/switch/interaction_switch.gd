extends InteractionComponent
class_name InteractionSwitch

# Switch Variables
var switch_target_rotation: float = 0.0
var switch_lerp_speed: float = 8.0
var is_switch_snapping: bool = false
var switch_moved: bool = false
var last_switch_angle: float = 0.0   # angle of the door on the previous frame
var switch_creak_velocity_threshold: float = 0.01
var switch_fade_speed: float = 50.0
var switch_kickback_triggered: bool = false

func _ready() -> void:
	super._ready()
	var balloon : BalloonController = get_tree().get_first_node_in_group("balloon") as BalloonController
	if balloon: nodes_to_affect.append(balloon)
	if object_ref: starting_rotation = object_ref.rotation.z
	maximum_rotation = deg_to_rad(rad_to_deg(starting_rotation)+maximum_rotation)

func _process(delta: float) -> void:
	if is_interacting:
		update_switch_sounds(delta)
	else:
		stop_switch_sounds(delta) 

	if is_switch_snapping:
		# Trigger the kickback and play the sound only once at start
		if not switch_kickback_triggered:
			switch_kickback_triggered = true
			if secondary_se and not secondary_audio_player.playing:
				secondary_audio_player.stop()
				secondary_audio_player.volume_db = 0.0
				secondary_audio_player.play()
		object_ref.rotation.z = lerp(object_ref.rotation.z, switch_target_rotation, delta * switch_lerp_speed)

		# Stop snapping when close enough
		if abs(object_ref.rotation.z - switch_target_rotation) < 0.01:
			object_ref.rotation.z = switch_target_rotation
			is_switch_snapping = false
			var percentage: float = (object_ref.rotation.z - starting_rotation) / (maximum_rotation - starting_rotation)
			notify_nodes(percentage)
	else:
		switch_kickback_triggered = false

func _input(event):
	if not is_interacting: return

	if event is InputEventMouseMotion:
		var prev_angle = object_ref.rotation.z
		object_ref.rotate_z(-event.relative.y * .001)
		object_ref.rotation.z = clamp(object_ref.rotation.z, starting_rotation, maximum_rotation)
		# var percentage: float = (object_ref.rotation.z - starting_rotation) / (maximum_rotation - starting_rotation)
		
		if abs(object_ref.rotation.z - prev_angle) > 0.01:
			switch_moved = true
			
		# notify_nodes(percentage)

func preInteract(hand: Marker3D, target: Node = null) -> void:
	super.preInteract(hand, target)
	lock_camera = true
	switch_moved = false

func postInteract() -> void:
	super.postInteract()
	var percent := (object_ref.rotation.z - starting_rotation) / (maximum_rotation - starting_rotation)
	if percent < 0.5:
		switch_target_rotation = starting_rotation
		is_switch_snapping = true
	elif percent > 0.5:
		switch_target_rotation = maximum_rotation
		is_switch_snapping = true

func update_switch_sounds(delta: float) -> void:
	# Calculate angular speed
	var angular_speed = abs(object_ref.rotation.z - last_switch_angle) / max(delta, 0.0001)
	last_switch_angle = object_ref.rotation.z

	# Determine target volume based on threshold
	var target_volume: float = 0.0
	if angular_speed > switch_creak_velocity_threshold:
		pass
		# target_volume = clamp((angular_speed - switch_creak_velocity_threshold) * creak_volume_scale, 0.0, 1.5)

	# Start pull sound if needed
	if not primary_audio_player.playing and primary_se and target_volume > 0:
		primary_audio_player.volume_db = -15.0
		primary_audio_player.play()
		
	# Smooth fade in/out
	if primary_audio_player.playing:
		var current_vol = db_to_linear(primary_audio_player.volume_db)
		var new_vol = lerp(current_vol, target_volume, delta * switch_fade_speed)
		primary_audio_player.volume_db = linear_to_db(clamp(new_vol, 0.0, 1.5))

	# Play "thunk" when snapping completes
	if switch_moved:
		if abs(object_ref.rotation.z - maximum_rotation) < 0.01 or abs(object_ref.rotation.z - starting_rotation) < 0.01:
			if secondary_se:
				secondary_audio_player.volume_db = -0.0
				secondary_audio_player.play()
			switch_moved = false  # reset after playing

func stop_switch_sounds(delta: float) -> void:
	if primary_audio_player and primary_audio_player.playing:
		var current_vol = db_to_linear(primary_audio_player.volume_db)
		var new_vol = lerp(current_vol, 0.0, delta * switch_fade_speed)
		primary_audio_player.volume_db = linear_to_db(clamp(new_vol, 0.0, 1.0))

		# Stop completely once inaudible
		if new_vol < 0.001:
			primary_audio_player.stop()	
