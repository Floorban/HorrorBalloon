extends InteractionComponent
class_name InteractionVehicle

@export var viewing_offet : Vector3 = Vector3(0, 5.0, -0.5)
@export var viewing_zoom : float = 0.8

@export var interact_area: Area3D

var forward := 0.0
var right := 0.0
var accel_speed := 3.0 # how quickly input ramps up
var decay_speed := 5.0 # how quickly it resets when released

func _ready() -> void:
	super._ready()
	can_interact = false
	if interact_area:
		interact_area.body_entered.connect(_on_player_entered)
		interact_area.body_exited.connect(_on_player_exited)

func _physics_process(delta):
	if not is_occupied:
		forward = 0.0
		right = 0.0
		notify_nodes(forward, true)
		notify_nodes(right, false)
		return
	
	var target_forward := Input.get_action_strength("forward") - Input.get_action_strength("backward")
	var target_right := Input.get_action_strength("right") - Input.get_action_strength("left")
	
	forward = move_toward(forward, target_forward, accel_speed * delta)
	right = move_toward(right, target_right, accel_speed * delta)
	
	forward = clamp(forward, -1.0, 1.0)
	right = clamp(right, -1.0, 1.0)

	notify_nodes(forward, true)
	notify_nodes(right, false)

func _input(event):
	if not is_occupied: return
	if event.is_action_pressed("pickup"):
		exit_vehicle()

func preInteract(_hand: Marker3D, _target: Node = null) -> void:
	super.preInteract(_hand, _target)
	enter_vehicle()

func interact_hint() -> void:
	pass

func disable_interact_hint() -> void:
	pass

func enter_vehicle() -> void:
	if not is_occupied and can_interact:   
		player.set_viewing_mode(viewing_offet, viewing_zoom)
		is_occupied = true
		can_interact = false

func exit_vehicle() -> void:
	if not player: return
	player.set_viewing_mode()
	is_interacting = false
	is_occupied = false
	await get_tree().create_timer(0.3).timeout
	can_interact = true

func _on_player_entered(body: Node3D) -> void:
	if body is PlayerController:
		can_interact = true

func _on_player_exited(body: Node3D) -> void:
	if body is PlayerController:
		can_interact = false
		body.interaction_controller._unfocus()
