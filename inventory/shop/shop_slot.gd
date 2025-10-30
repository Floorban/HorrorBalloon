extends Slot
class_name ShopSlot

#func swap_slot(target_slot) -> void:
	#if target_slot is SeatSlot:
		#var _tmp = guest
		#guest = target_slot.guest
		#target_slot.guest = _tmp
		#update_ui()
		#target_slot.update_ui()
		#if target_slot.has_content():
			#target_slot._anim_punch_effect()
	#elif target_slot is ItemSlot:
		#if guest:
			#guest.receive_item(target_slot.item)
		#target_slot.item = null
		#target_slot.update_ui()
	#_anim_punch_effect()

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	if _data is ShopSlot: 
		return true
	return false

func swap_slot(target_slot: Slot) -> void:
	if target_slot is ShopSlot:
		var tmp = item
		item = target_slot.item
		target_slot.item = tmp
		update_ui()
		target_slot.update_ui()
		if target_slot.has_content():
			target_slot._anim_punch_effect()
	elif target_slot is ItemSlot:
		Shop.buy_item(item)
		target_slot.item = null
		target_slot.update_ui()
	_anim_punch_effect()
