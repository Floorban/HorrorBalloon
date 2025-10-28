extends Node

signal game_start

@onready var player : PlayerController = get_tree().get_first_node_in_group("player")

var current_level := 1
var attempts := 1

func _ready() -> void:
	if player: player.cave_gen.finish_gen.connect(set_game_state)

func get_current_level() -> int:
	return current_level

func set_current_level(level: int) -> void:
	current_level = level

func get_game_state() -> void:
	pass

func set_game_state() -> void:
	print("game starts")
	game_start.emit()
