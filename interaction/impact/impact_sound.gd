extends RigidBody3D

@export var sfx_impact: String = "event:/SFX/Interactables/Impact/Can"
@export var impact_parameter: String = "impact_strength"

var i_impact: FmodEvent
var has_collided: bool = false

func _ready() -> void:
	if sfx_impact != "":
		i_impact = FmodServer.create_event_instance(sfx_impact)
		pass

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if state.get_contact_count() > 0 and not has_collided:
		var max_intensity: float = 0.0

		for i in state.get_contact_count():
			var contact_velocity = state.get_contact_local_velocity_at_position(i)
			var impact_velocity: float = contact_velocity.length()

			var mass_factor: float = mass * 0.01
			var intensity: float = impact_velocity * mass_factor
			intensity = clamp(intensity, 0.0, 1.0)

			max_intensity = max(max_intensity, intensity)

		if max_intensity <= 0.05: return
		if i_impact:
			i_impact.set_3d_attributes(global_transform)
			i_impact.set_parameter_by_name(impact_parameter, max_intensity)
			i_impact.start()
			i_impact.release()

		print(max_intensity)

	elif state.get_contact_count() == 0:
		has_collided = false
