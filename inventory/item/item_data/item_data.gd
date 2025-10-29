extends Resource
class_name ItemData

@export var item_name := ""
@export var icon : Texture2D
@export var mesh_scene : PackedScene
@export var scene_path : String

func use_item() -> void:
	print(item_name, "is being used")
