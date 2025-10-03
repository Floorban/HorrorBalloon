extends Node
class_name InteractionController

@onready var balloon: BalloonController = get_tree().get_first_node_in_group("balloon")

@onready var interaction_raycast: RayCast3D = %InteractionRaycast
@onready var player: PlayerController = $".."
@onready var player_camera: Camera3D = %Camera3D
var current_object: Object
var last_potential_object: Object
var interaction_component: InteractionComponent

@onready var hand: Marker3D = %Hand
@onready var chest: Marker3D = %Chest

# UI
var ui_alpha := 0.0
var ui_target_alpha := 0.0
var ui_speed := 5.0
var is_focused: bool = false
@onready var default_reticle: TextureRect = %DefaultReticle
@onready var highlight_reticle: TextureRect = %HighlightReticle
@onready var interacting_reticle: TextureRect = %InteractingReticle
@onready var interactable_check: Area3D = $"../InteractableCheck"

@onready var ui_background: PanelContainer = %UIBackground
@onready var ui_spawn_root: Control = %InteractionControlSpawnRoot
#@onready var interaction_ui_scene: PackedScene = preload("uid://cgy2ke6mlhmar")
@onready var interactoin_uis : Array[Control] = [%InteractoinUI1, %InteractoinUI2, %InteractoinUI3]

@onready var outline_material: Material = preload("res://materials/item_highlighter.tres")

func ui_init() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var screen_size = get_viewport().get_visible_rect().size
	default_reticle.position = screen_size / 2 - default_reticle.texture.get_size() / 2
	highlight_reticle.position = screen_size / 2 - highlight_reticle.texture.get_size() / 2
	interacting_reticle.position = screen_size / 2 - interacting_reticle.texture.get_size() / 2
	interaction_ui_clear()

func _ready() -> void:
	interactable_check.body_entered.connect(_collectible_item_entered_range)
	interactable_check.body_exited.connect(_collectible_item_exited_range)
	ui_init()

func perform_interactions(target: InteractionComponent) -> void:
	# Update reticle
	if interaction_component.is_interacting:
		default_reticle.visible = false
		highlight_reticle.visible = false
		interacting_reticle.visible = true
	# Limit interaction distance
	elif player_camera.global_transform.origin.distance_to(current_object.global_transform.origin) > 3.0:
		interaction_component.postInteract()
		current_object = null
		_unfocus()
		return
	if Input.is_action_just_pressed("secondary"):
		target.auxInteract()
		stop_interactions()
	elif Input.is_action_pressed("primary"):
		target.interact()
	else:
		target.postInteract()
		stop_interactions()

func stop_interactions() -> void:
	current_object = null 
	_unfocus()

func check_potential_interactables() -> void:
	var potential_object: Object = interaction_raycast.get_collider()
	
	if potential_object and potential_object is Node:
		var node: Node = potential_object
		interaction_component = null
		while node:
			interaction_component = node.get_node_or_null("InteractionComponent")
			if interaction_component:
				break
			node = node.get_parent()
		if interaction_component:
			if interaction_component.can_interact == false:
				return
				
			last_potential_object = current_object
			_focus()
			if Input.is_action_just_pressed("primary"):
				current_object = potential_object
				interaction_component.preInteract(hand, current_object)
				
				if interaction_component is InteractionCollectable:
					interaction_component.connect("item_collected", Callable(self, "_on_item_collected"))
				
				if interaction_component is InteractionClimb:
					interaction_component.check_player_side(interaction_raycast)
				
				if interaction_component is InteractionDoor:
					interaction_component.set_direction(balloon.objs_in_balloon.has(balloon.player))
		else: 
			# If the object just looked at cant be interacted with, call unfocus
			stop_interactions()
	else:
		stop_interactions()

func _process(delta: float) -> void:
	if not player.can_move:
		default_reticle.visible = false
		highlight_reticle.visible = false
		interacting_reticle.visible = false
		return
	# If on the previous frame, keep interacting with it
	if current_object:
		if interaction_component:
			perform_interactions(interaction_component)
		else:
			stop_interactions()
	else:
		check_potential_interactables()
	
	ui_alpha = lerp(ui_alpha, ui_target_alpha, delta * ui_speed)
	ui_background.modulate.a = ui_alpha
	ui_background.visible = ui_alpha > 0.01

## If the object the player is interacting with should stop mouse camera movement
func is_cam_locked() -> bool:
	if interaction_component:
		if interaction_component.lock_camera and interaction_component.is_interacting:
			return true
	return false

func interaction_ui_init() -> void:
	if not interaction_component or interaction_component.ui_set.size() <= 0:
		return
	for ui in interactoin_uis: ui.visible = false
	var i := 0
	for ui_data in interaction_component.ui_set:
		if i >= interactoin_uis.size():
			break
		var ui = interactoin_uis[i]
		ui.visible = true
		if ui.has_method("init_data"):
			ui.init_data(ui_data)
		i += 1
	
	ui_background.visible = true
	ui_target_alpha = 1.0
	
	#for ui_data in interaction_component.ui_set: 
		#var ui_instance = interaction_ui_scene.instantiate()
		#ui_spawn_root.add_child(ui_instance)
		#if ui_instance.has_method("init_data"): ui_instance.init_data(ui_data)
		
	#if ui_tween: ui_tween.kill()
	#parent.modulate.a = 0.0
	#ui_tween = create_tween()
	#ui_tween.tween_property(parent, "modulate:a", 1.0, 0.25) \
		#.set_trans(Tween.TRANS_CUBIC) \
		#.set_ease(Tween.EASE_OUT)

func interaction_ui_clear() -> void:
	ui_background.visible = false
	ui_target_alpha = 0.0
	
	#if ui_tween: ui_tween.kill()
	#ui_tween = create_tween()
	#ui_tween.tween_property(parent, "modulate:a", 0.0, 0.35) \
		#.set_trans(Tween.TRANS_CUBIC) \
		#.set_ease(Tween.EASE_IN)
	#ui_tween.tween_callback(Callable(parent, "set_visible").bind(false))

## Called when the player is looking at an interactable objects
func _focus() -> void:
	if is_focused:
		return
	is_focused = true
	default_reticle.visible = false
	highlight_reticle.visible = true
	interacting_reticle.visible = false
	interaction_ui_init()

## Called when the player is NOT looking at an interactable objects
func _unfocus() -> void:
	if not is_focused:
		return
	is_focused = false
	default_reticle.visible = true
	highlight_reticle.visible = false
	interacting_reticle.visible = false
	interaction_ui_clear()

## Called when the player collects an item
func _on_item_collected(item: Node):
	# TODO: INVENTORY SYSTEM would handle storing this item here.
	print("Player Collected: ", item)

## Called when a collectible item is within range of the player
func _collectible_item_entered_range(body: Node3D) -> void:
	# TODO: Use Collision layers to ignore collisions with the player
	if body.name != "Player":
		var ic = body.get_node_or_null("InteractionComponent")
		if ic and ic is InteractionComponent:
			var mesh: MeshInstance3D = body.find_child("MeshInstance3D", true, false)
			mesh.material_overlay = outline_material

## Called when a collectible item is NO LONGER within range of the player
func _collectible_item_exited_range(body: Node3D) -> void:
	# TODO: Use Collision layers to ignore collisions with the player
	if body.name != "Player":
		var mesh: MeshInstance3D = body.find_child("MeshInstance3D", true, false)
		if mesh:
			mesh.material_overlay = null
