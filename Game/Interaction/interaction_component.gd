extends Node
class_name  InteractionComponent

enum InteractionType {
	NONE,
	PICKUP,
	DROP,
	EXAMINE,
	USE
}

@export var interaction_type: InteractionType = InteractionType.NONE
@export var object_ref : Node3D

func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	pass
