@tool
extends InteractionComponent
class_name InteractionInspect

signal note_collected(note: Node3D)

var content: String

func _ready() -> void:
	super._ready()
	content = content.replace("\\n", "\n")

func interact() -> void:
	super.interact()
	_collect_note()

## Fires a signal that a player has picked up a note/log
func _collect_note() -> void:
	var col = get_parent().find_child("CollisionShape3D", true, false)
	var mesh = get_parent().find_child("MeshInstance3D", true, false)
	if mesh:
		mesh.layers = 2
	if col:
		col.get_parent().remove_child(col)
		col.queue_free()
	_play_primary_sound_effect(true, false)
	emit_signal("note_collected", get_parent())
