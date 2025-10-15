extends Node3D

@export var controller_scenes : Array[PackedScene]
var timer := 0.0

func _ready():
	start_level()

func _physics_process(delta: float) -> void:
	timer += delta

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("next_level"):
		next_level()
	elif event.is_action_pressed("previous_level"):
		previous_level()
	elif event.is_action_pressed("restart"):
		Global.attempts += 1
		restart_level(Global.get_current_level())

func start_level():
	var index = Global.get_current_level() - 1
	if index < 0 or index >= controller_scenes.size():
		return
	spawn_controller(controller_scenes[index])

func restart_level(level_index : int):
	Global.set_current_level(level_index)
	get_tree().reload_current_scene()

func previous_level():
	Global.attempts = 1
	if Global.get_current_level() - 1 < 0:
		restart_level(controller_scenes.size())
	else:
		restart_level(Global.get_current_level() - 1)

func next_level():
	print("level %d's attempts: %d" % [Global.get_current_level(), Global.attempts])
	print("level %d's time spent: %f" % [Global.get_current_level(), timer])	
	Global.attempts = 1
	if Global.get_current_level() - 1 >= controller_scenes.size():
		restart_level(1)
	else:
		restart_level(Global.get_current_level() + 1)

func spawn_controller(controller_scene: PackedScene):
	var controller_instance = controller_scene.instantiate()
	add_child(controller_instance)
