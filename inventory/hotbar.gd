extends HBoxContainer

var slots : Array

@export var select_box : TextureRect

func _ready() -> void:
	get_slots()
	ItemInventory.inventory_changed.connect(_update_hotbar)
	ItemInventory.slot_selected.connect(_highlight_hotbar)
	ItemInventory.slot_emptied.connect(_reset_hotbar)
	_update_hotbar()

func get_slots():
	slots = get_children()
	for slot : TextureButton in slots:
		slot.pressed.connect(ItemInventory.select_slot.bind(slot.get_index()))

func _update_hotbar():
	for i in range(slots.size()):
		var slot_btn: TextureButton = slots[i]
		var slot_data: ItemSlot = ItemInventory.hotbar[i]

		if slot_data.is_empty():
			slot_btn.texture_normal = null
			slot_btn.get_node("CountLabel").text = ""
		else:
			slot_btn.texture_normal = slot_data.item.icon
			slot_btn.get_node("CountLabel").text = str(slot_data.count)

func _highlight_hotbar(slot_index : int):
	for i in range(ItemInventory.hotbar_size):
		slots[i].modulate = Color(1,1,1)
	
	var selected_slot = slots[slot_index]
	selected_slot.modulate = Color(1.5,1.5,1.5)
	if select_box and not ItemInventory.get_current_slot().is_empty():
		select_box.visible = true
		select_box.global_position = selected_slot.global_position

func _reset_hotbar():
	if select_box: select_box.visible = false
