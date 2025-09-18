class_name Interactable
extends RigidBody3D

var player : PlayerController

@onready var mesh: MeshInstance3D = $Mesh
@onready var outline_mesh: MeshInstance3D = $Mesh/OutlineMesh

@onready var collision: CollisionShape3D = $CollisionShape3D
var selected := false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if player: player.interact_obj.connect(_set_selected)
	outline_mesh.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interaction") and selected:
		player.pick_up_obj(self)

func _process(_delta: float) -> void:
	collision.disabled = player == get_parent()
	outline_mesh.visible = selected and not player == get_parent()

func _set_selected(obj):
	selected = self == obj
