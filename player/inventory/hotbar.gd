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
	for slot : TextureButton in slots:
		var item = ItemInventory.hotbar[slot.get_index()]
		slot.texture_normal = item.icon if item else null

func _highlight_horbar(slot_index : int):
	for i in range(3):
		slots[i].modulate = Color(1,1,1)
	slots[slot_index].modulate = Color(3,3,3)
