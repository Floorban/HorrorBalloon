extends SpotLight3D
class_name Objective

@onready var default_light_energy: float = self.light_energy

func execute(_percentage: float) -> void:
	light_energy = (1 - _percentage) * default_light_energy
