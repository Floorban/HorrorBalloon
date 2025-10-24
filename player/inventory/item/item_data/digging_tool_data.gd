extends Resource
class_name DiggingToolData

@export var max_durability := 20
@export var digging_detection_range := 1.0
@export var max_digging_size := 0.5

@export var digging_sfxs : Array[DiggingSfxData]

func get_digging_sfx(material : String) -> DiggingSfxData:
	for sfx in digging_sfxs:
		if material == sfx.mat_name:
			return sfx
	return null
