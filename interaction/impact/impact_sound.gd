#extends RigidBody3D
#
#@export var SFX_Impact: String = "event:/SFX/Interactables/Impact/Can"
#
#var can_play: bool = false
#var disabled: bool = false
#var has_collided: bool = false
#var cooldown: float = 0.5
#var last_play_time: float = -10.0
#
#func _ready() -> void: last_play_time -= cooldown
#
#func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	##TODO: Sleep object if inactive for long but wakes up after being grabbed
	#var current_time: float = Time.get_ticks_msec() / 1000.0
	#if current_time <= 10.0: return
#
	#if state.get_contact_count() > 0:
		#var max_intensity: float = 0.0
#
		#for i in state.get_contact_count():
			##TODO: Respond to player signal to ignore collision
			#var contact_velocity = state.get_contact_local_velocity_at_position(i)
			#var impact_velocity: float = contact_velocity.length()
			#var mass_factor: float = mass * 0.01
			#var intensity: float = impact_velocity * mass_factor
			#intensity = clamp(intensity, 0.0, 0.3)
#
			#max_intensity = max(max_intensity, intensity)
#
		## Plays sound only if collision intensity is strong enough and no cooldown
		#if max_intensity > 0.05 and current_time - last_play_time >= cooldown:
			#FmodServer.play_one_shot_attached_with_params(SFX_Impact, self, {"impact_strength": max_intensity})
			#last_play_time = current_time
			#print("Impact intensity:", max_intensity)
#
		#has_collided = true
#
	#else:
		#has_collided = false
