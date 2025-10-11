extends Camera3D

@onready var spring_position: Node3D = $"../SpringArm3D/SpringPosition"
@export var lerp_power := 1.0

func _process(delta: float) -> void:
	position = lerp(position, spring_position.position, delta * lerp_power)
