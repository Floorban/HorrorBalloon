extends Node3D
class_name AudioManager

## -- Mixer Settings -- ##
@export_range(0, 100, 1) var master_volume: float = 100
@export_range(0, 100, 1) var ambient_volume: float = 100
@export_range(0, 100, 1) var music_volume: float = 100
@export_range(0, 100, 1) var sfx_volume: float = 100
var master_bus: FmodBus
var ambient_bus: FmodBus
var music_bus: FmodBus
var sfx_bus: FmodBus

## -- Developer Settings --
@export var developer_mode: bool = false
@export var test_name: String
var test_event: FmodEvent = null

func _ready():
	play_sound(test_name)

func play_sound(event_name: String, source_transform : Transform3D = global_transform):
	var event: FmodEvent = FmodServer.create_event_instance(event_name)
	if source_transform == global_transform :
		event.set_3d_attributes(source_transform)
	event.start()
	event.release()
	pass
