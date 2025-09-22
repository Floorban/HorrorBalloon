class_name InteractionComponent
extends Node

@export var object_ref: Node3D
@export var nodes_to_affect: Array[Node]

@export var pivot_point: Node3D
@export var maximum_rotation: float = 90

var player : PlayerController
@export var weight: float = 1.0

# Common Variables
var can_interact: bool = true
var is_interacting: bool = false
var lock_camera: bool = false
var starting_rotation: float
var player_hand: Marker3D
var camera: Camera3D
var previous_mouse_position: Vector2

# SoundEffects
var primary_audio_player: AudioStreamPlayer3D
var secondary_audio_player: AudioStreamPlayer3D
var tertiary_audio_player: AudioStreamPlayer3D
var last_velocity: Vector3 = Vector3.ZERO
var contact_velocity_threshold: float = 1.0
@export var primary_se: AudioStreamOggVorbis
@export var secondary_se: AudioStreamOggVorbis
@export var tertiary_se: AudioStreamOggVorbis

# func get_prefab_root() -> Node:
# 	var node := self
# 	while node.get_parent() != null and not node.get_parent() is Tree:
# 		node = node.get_parent()
# 	return node

func _ready() -> void:
	# object_ref = get_prefab_root()
	player = get_tree().get_first_node_in_group("player")
	# if player is PlayerController: camera = player.player_camera
	# Initialize Audio
	primary_audio_player = AudioStreamPlayer3D.new()
	primary_audio_player.stream = primary_se
	add_child(primary_audio_player)
	secondary_audio_player = AudioStreamPlayer3D.new()
	secondary_audio_player.stream = secondary_se
	add_child(secondary_audio_player)
	tertiary_audio_player = AudioStreamPlayer3D.new()
	tertiary_audio_player.stream = tertiary_se
	add_child(tertiary_audio_player)

## Runs once, when the player FIRST clicks on an object to interact with
func preInteract(_hand: Marker3D, _target: Node = null) -> void:
	is_interacting = true
	
## Run every frame while the player is interacting with this object
func interact() -> void:
	if not can_interact:
		return

## Alternate interaction using secondary button
func auxInteract() -> void:
	if not can_interact:
		return
	
## Runs once, when the player LAST interacts with an object
func postInteract() -> void:
	is_interacting = false
	lock_camera = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

## Iterates over a list of nodes that can be interacted with and executes their respective logic
func notify_nodes(percentage: float) -> void:
	for node in nodes_to_affect:
		if node and node.has_method("execute"):
			node.call("execute", percentage)
	
## Default method to play the primary sound effect of a given object
func _play_primary_sound_effect(visible: bool, _interact: bool) -> void:
	if primary_se:
		primary_audio_player.play()
		get_parent().visible = visible
		self.can_interact = _interact
		await primary_audio_player.finished
		
## Fires when a default object collides with something in the world
func _fire_default_collision(_node: Node) -> void:
	var impact_strength = (last_velocity - object_ref.linear_velocity).length()
	if impact_strength > contact_velocity_threshold:
		_play_primary_sound_effect(true, true)
