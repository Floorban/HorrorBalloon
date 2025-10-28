extends SpotLight3D
class_name Objective

@onready var default_light_energy: float = self.light_energy

func execute(percentage: float, primary: bool) -> void:
	light_energy = (1 - percentage) * default_light_energy
