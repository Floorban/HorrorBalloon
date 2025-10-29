extends Node

signal inventory_changed
signal slot_selected(slot_index : int)
signal item_drop(item_instance)

var hotbar_size := 3
var hotbar : Array[ItemSlot]
var selecting_slot : int = 0

var use_item_key := "primary"
var drop_item_key := "secondary"
var drop_slot_key := "drop"

func _init() -> void:
	hotbar.resize(hotbar_size)
	for i in range(hotbar_size):
		hotbar[i] = ItemSlot.new()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(use_item_key):
		use_item(selecting_slot)
	elif event.is_action_pressed(drop_item_key):
		drop_item(selecting_slot)
	elif event.is_action_pressed(drop_slot_key):
		drop_slot(selecting_slot)

func add_item(item: ItemData, amount: int = 1) -> bool:
	# try stack first
	for i in range(hotbar_size):
		var slot = hotbar[i]
		if slot.can_stack(item):
			var space_left = slot.item.max_stack - slot.count
			var to_add = min(space_left, amount)
			slot.count += to_add
			amount -= to_add
			inventory_changed.emit()
			slot_selected.emit(i)
			selecting_slot = i
			if amount <= 0:
				return true

	# try put in empty slots
	for i in range(hotbar_size):
		var slot = hotbar[i]
		if slot.is_empty():
			slot.item = item
			slot.count = min(amount, item.max_stack if item.is_stackable else 1)
			amount -= slot.count
			inventory_changed.emit()
			slot_selected.emit(i)
			selecting_slot = i
			if amount <= 0:
				return true

	print("Inventory full — couldn't add", amount, item.item_name)
	return false

func select_slot(index : int):
	selecting_slot = clamp(index, 0, hotbar_size - 1)
	slot_selected.emit(selecting_slot)

func spawn_item_instance(item: ItemData):
	if item.scene_path == "":
		return
	var pickup_scene = load(item.scene_path)
	if not pickup_scene:
		return
	var item_instance = pickup_scene.instantiate()
	
	item_instance.get_node_or_null("InteractionComponent").item_data = item
	get_tree().current_scene.add_child(item_instance)
	item_drop.emit(item_instance)

func drop_item(slot_index: int):
	var slot = hotbar[slot_index]
	if slot.is_empty():
		return

	spawn_item_instance(slot.item)
	slot.count -= 1
	if slot.count <= 0:
		slot.item = null

	inventory_changed.emit()
	if slot_index == selecting_slot:
		slot_selected.emit(selecting_slot)

func drop_slot(slot_index : int):
	var slot : ItemSlot = hotbar[slot_index]
	if slot.is_empty():
		return
	
	var total_to_drop = slot.count
	for i in range(total_to_drop):
		drop_item(slot_index)

func get_current_item() -> ItemData:
	return hotbar[selecting_slot].item

func use_item(slot_index : int):
	if hotbar[slot_index]:
		var item_to_use = hotbar[slot_index]
		item_to_use.use_item()
