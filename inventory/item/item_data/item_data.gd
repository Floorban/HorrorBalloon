extends Resource
class_name ItemData

@export var item_name := ""
@export var icon : Texture2D
@export var mesh_scene : PackedScene
@export var scene_path : String

@export var is_stackable := true
@export var max_stack := 4

@export var is_sellable := true
@export var buy_price : int
@export var sell_price : int

func use_item() -> void:
	print(item_name, "is being used")
