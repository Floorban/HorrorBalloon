extends RigidBody3D
class_name DiggingTool

@export var tool_data : DiggingToolData

var durability : float
var digging_range: float
var digging_size: float

func tool_init() -> void:
	durability = tool_data.max_durability
	digging_range = tool_data.digging_detection_range
	digging_size = tool_data.max_digging_size

func _ready() -> void:
	tool_init()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("primary"):
		print("1")

func get_digging_sfx() -> String:
	return ""
