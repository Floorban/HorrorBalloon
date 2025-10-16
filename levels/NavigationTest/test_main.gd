extends Node3D

@export var controller_scenes : Array[PackedScene]
var timer := 0.0
var level_started := false

@export var win_area: PackedScene
@export var win_spawn_point: Array[Marker3D]

func _ready():
	start_level()

func _physics_process(delta: float) -> void:
	if level_started:
		timer += delta

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not level_started:
		level_started = true
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
	spawn_win_area()

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

func spawn_win_area():
	var random_index = randi() % win_spawn_point.size()
	var spawn_transform = win_spawn_point[random_index].global_transform
	var win_instance = win_area.instantiate()
	win_instance.global_transform = spawn_transform
	add_child(win_instance)
	win_instance.body_entered.connect(_on_win_body_entered)

func _on_win_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		next_level()
