@tool
extends VoxelTerrain
class_name Voxel

@export var texture1 : Texture2D
@export var texture2 : Texture2D
@export var texture3 : Texture2D

@export var voxel_data: Array[CaveVoxelData] = []

func _ready() -> void:
	var texture_2d_array := Texture2DArray.new()
	texture_2d_array.create_from_images([texture1.get_image(), texture2.get_image(), texture3.get_image()])
	material_override.set("shader_parameter/u_texture_array", texture_2d_array)