extends Node3D
class_name AudioManager

## -- Mixer Settings --
@export_range(0.0, 100.0, 1.0) var master_volume: float = 100.0
@export_range(0.0, 100.0, 1.0) var ambient_volume: float = 100.0
@export_range(0.0, 100.0, 1.0) var music_volume: float = 100.0
@export_range(0.0, 100.0, 1.0) var sfx_volume: float = 100.0
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

func _physics_process(_delta: float) -> void:
	listener.global_transform = player.global_transform

func cache(emitter: FmodEventEmitter3D, emit_position: Vector3) -> FmodEventEmitter3D:
	emitter.global_position = emit_position
	emitter.allow_fadeout = true
	emitter.attached = true
	emitter.auto_release = false
	emitter.play()
	emitter.paused = true
	return emitter

func initiate(emitter: FmodEventEmitter3D) -> FmodEventEmitter3D:
	emitter.allow_fadeout = true
	emitter.attached = true
	emitter.auto_release = false
	emitter.play()
	return emitter
