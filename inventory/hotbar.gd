extends HBoxContainer

var slots : Array

func _ready() -> void:
	get_slots()
	ItemInventory.inventory_changed.connect(_update_hotbar)
	ItemInventory.slot_selected.connect(_highlight_horbar)
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

func _highlight_horbar(slot_index : int):
	for i in range(3):
		slots[i].modulate = Color(1,1,1)
	slots[slot_index].modulate = Color(3,3,3)
