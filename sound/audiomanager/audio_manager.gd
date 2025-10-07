extends Node3D

## -- Banks Settings -- 
var bank_list: Dictionary
const MASTER_STRINGS_BANK: String = "res://sound/banks/Desktop/Master.strings.bank"
const MASTER_BANK: String = "res://sound/banks/Desktop/Master.bank"
const BALLOON_BANK: String = "res://sound/banks/Desktop/Balloon.bank"
const OUTSIDE_BANK: String = "res://sound/banks/Desktop/Outside.bank"

## -- Mixer Settings --
@export_range(0.0, 100.0, 1.0) var master_volume: float = 100.0
@export_range(0.0, 100.0, 1.0) var ambient_volume: float = 100.0
@export_range(0.0, 100.0, 1.0) var music_volume: float = 100.0
@export_range(0.0, 100.0, 1.0) var sfx_volume: float = 100.0
var master_bus: FmodBus
var ambient_bus: FmodBus
var music_bus: FmodBus
var sfx_bus: FmodBus

## -- Playback Settings --
const PLAYING = FmodServer.FMOD_STUDIO_PLAYBACK_PLAYING
const STOPPED = FmodServer.FMOD_STUDIO_PLAYBACK_STOPPED

## -- Developer Settings --
@export var developer_mode: bool = false
@export var test_name: String
var test_event: FmodEvent = null

## -- Listener Settings
@onready var player: PlayerController
@onready var listener: FmodListener3D

func _ready() -> void: 
	load_banks()
	
	player = get_tree().get_first_node_in_group("player")
	listener = get_node("Essentials/FmodListener3D")

func _physics_process(_delta: float) -> void:
	if player != null: listener.global_transform = player.global_transform

func load_banks() -> void:
	bank_list["master_strings_bank"] = FmodServer.load_bank(MASTER_STRINGS_BANK, FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
	bank_list["master_bank"] = FmodServer.load_bank(MASTER_BANK, FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
	bank_list["balloon_bank"] = FmodServer.load_bank(BALLOON_BANK, FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
	bank_list["outside_bank"] = FmodServer.load_bank(OUTSIDE_BANK, FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)

func play(sound_path: String, object_transform: Transform3D = global_transform, parameter: String = "", value: Variant = null):
	var instance: FmodEvent = FmodServer.create_event_instance(sound_path)
	instance.set_3d_attributes(object_transform)
	
	if value is float: instance.set_parameter_by_name(parameter, value)
	if value is String: instance.set_parameter_by_name_with_label(parameter, value, false)
	else: pass
	
	instance.start()
	instance.release()
	return instance

func play_instance(sound_path: String, object: Node) -> FmodEvent:
	var instance: FmodEvent = FmodServer.create_event_instance(sound_path)
	instance.set_3d_attributes(object.global_transform)
	instance.start()
	return instance

func clear_instance(instance: FmodEvent):
	instance.stop(FmodServer.FMOD_STUDIO_STOP_ALLOWFADEOUT)
	instance.release()
