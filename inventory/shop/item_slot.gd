extends Slot
class_name ItemSlot

func _ready():
	super._ready()
	update_ui()

func set_item(_item: ItemData) -> void:
	item = _item
	update_ui()
	_anim_punch_effect()

#func update_ui():
	#if not item:
		#icon.texture = null
		#icon.hide()
		#return
	#icon.texture = item.icon
	#icon.show()

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is ItemSlot

func has_content() -> bool:
	return item != null

func swap_slot(target_slot: Slot) -> void:
	if target_slot is ItemSlot:
		var tmp = item
		item = target_slot.item
		target_slot.item = tmp
		update_ui()
		target_slot.update_ui()
		if target_slot.has_content():
			target_slot._anim_punch_effect()
