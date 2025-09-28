#extends RigidBody3D
#
#@onready var e_impact: FmodEventEmitter3D = $Impact
#@export var impact_parameter: String = "impact_strength"
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
	#var current_time: float = Time.get_ticks_msec() / 1000.0
	#if current_time <= 5.0: return
#
	#if state.get_contact_count() > 0:
		#var max_intensity: float = 0.0
#
		#for i in state.get_contact_count():
			#if state.get_contact_collider()
			#var contact_velocity = state.get_contact_local_velocity_at_position(i)
			#var impact_velocity: float = contact_velocity.length()
#
			#var mass_factor: float = mass * 0.01
			#var intensity: float = impact_velocity * mass_factor
			#intensity = clamp(intensity, 0.0, 0.3)
#
			#max_intensity = max(max_intensity, intensity)
#
		## Plays sound only if collision intensity is strong enough and no cooldown
		#if max_intensity > 0.05 and current_time - last_play_time >= cooldown:
			#e_impact.set_parameter(impact_parameter, max_intensity)
			#e_impact.play()
			#last_play_time = current_time
			#print("Impact intensity:", max_intensity)
#
		#has_collided = true
#
	#else:
		#has_collided = false
