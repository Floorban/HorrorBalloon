extends Node

signal inventory_changed
signal slot_selected(slot_index : int)
signal item_drop(item_instance)

var hotbar_size := 3
var hotbar : Array[ItemData]
var selecting_slot : int = 0

func _init() -> void:
	for i in hotbar_size:
		hotbar.append(null)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("secondary"):
		drop_item(selecting_slot)

func add_item(item: ItemData) -> bool:
	for i in hotbar_size:
		if hotbar[i] == null:
			hotbar[i] = item
			inventory_changed.emit()
			slot_selected.emit(i)
			return true
	return false

func select_slot(index : int):
	selecting_slot = clamp(index, 0, hotbar_size - 1)
	slot_selected.emit(selecting_slot)

func spawn_item_instance(item: ItemData):
	var item_instance = item.instance_scene.instantiate()
	item_instance.get_node_or_null("interactable").item_data = item
	get_tree().current_scene.add_child(item_instance)
	item_drop.emit(item_instance)

func drop_item(slot_index : int):
	if hotbar[slot_index]:
		var dropped_item = hotbar[slot_index]
		spawn_item_instance(dropped_item)
		hotbar[slot_index] == null
		if slot_index == selecting_slot:
			slot_selected.emit(selecting_slot)
