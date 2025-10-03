class_name InteractionComponent
extends Node

@onready var player : PlayerController = get_tree().get_first_node_in_group("player")

@export var ui_set: Array[InteractionUIData] = []
@export var object_ref: Node3D
@export var nodes_to_affect: Array[Node]
@export var maximum_rotation: float = 90

# Common Variables
var is_occupied := false
var can_interact: bool = true
var is_interacting: bool = false
var has_interacted: bool = false

var lock_camera: bool = false
var camera: Camera3D
var player_hand: Marker3D

var starting_rotation: float
var previous_mouse_position: Vector2
var last_velocity: Vector3 = Vector3.ZERO
var contact_velocity_threshold: float = 1.0


func _ready() -> void:
	pass

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
