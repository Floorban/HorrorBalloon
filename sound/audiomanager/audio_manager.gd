extends Node3D
class_name AudioManager

## -- Mixer Settings --
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

## -- Listener Settings
@onready var player: PlayerController
@onready var listener: FmodListener3D

func _ready() -> void:
	# references
	player = get_tree().get_first_node_in_group("player")
	listener = get_node("Essentials/FmodListener3D")

func _process(_delta: float) -> void:
	listener.global_transform = player.global_transform

func play(event_name: String, source_transform : Transform3D = global_transform):
	var event: FmodEvent = FmodServer.create_event_instance(event_name)
	if event.is_valid():
		if source_transform == global_transform : event.set_3d_attributes(source_transform)
		event.start()
		event.release()
	else: print(event_name + " not found, check for spelling mistakes!")
	pass
