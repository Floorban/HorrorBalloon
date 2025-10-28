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

func get_digging_sfx() -> String:
	return ""
