extends Node3D

var current_item_instance : Node3D

func _ready():
	ItemInventory.slot_selected.connect(_update_held_item)
	ItemInventory.inventory_changed.connect(_update_held_item_after_change)
 
func clear_item():
	if current_item_instance:
		current_item_instance.queue_free()
		current_item_instance = null
 
func show_item(item_data: ItemData):
	clear_item()
	if item_data and item_data.mesh_scene:
		current_item_instance = item_data.mesh_scene.instantiate()
		current_item_instance.position = Vector3.ZERO
		current_item_instance.rotation = Vector3.ZERO
		add_child(current_item_instance)
 
func _update_held_item(slot_index: int):
	var slot: ItemSlot = ItemInventory.hotbar[slot_index]
	show_item(slot.item if slot and not slot.is_empty() else null)

func _update_held_item_after_change():
	var slot_index = ItemInventory.selecting_slot
	_update_held_item(slot_index)
