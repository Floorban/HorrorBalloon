extends InteractionComponent
class_name InteractionCollectable

signal item_collected(item: Node)

func _ready() -> void:
	super._ready()

func interact() -> void:
	super.interact()
	_collect_item()

## Fires a signal that a player has picked up a collectible item
func _collect_item() -> void:
	emit_signal("item_collected", get_parent())
	await _play_primary_sound_effect(false, false)
	get_parent().queue_free()
