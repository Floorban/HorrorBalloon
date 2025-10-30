extends Control
class_name Slot

signal slot_focused(item: ItemData)
signal slot_unfocused()

@export var item: ItemData
var count: int = 0
@onready var icon: TextureRect = $Icon

func _ready() -> void:
	self.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	self.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	update_ui()

func update_ui():
	if not item:
		icon.texture = null
		icon.hide()
		tooltip_text = ""
		slot_unfocused.emit()
		return
	icon.texture = item.icon
	icon.show()
	tooltip_text = item.item_name

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not has_content():
		return null
	set_drag_preview(_create_drag_preview())
	icon.hide()
	return self

func _create_drag_preview() -> Control:
	var drag_preview = duplicate()
	drag_preview.rotation_degrees = 0
	drag_preview.position = Vector2.ZERO
	drag_preview.self_modulate = Color.TRANSPARENT
	var container = Control.new()
	container.add_child(drag_preview)
	drag_preview.position += Global.UI_DRAG_OFFSET
	return container

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	# overrided by the implementations
		#if data is SeatSlot:
			#return true
		#elif data is ItemSlot:
			#return has_content()
		#return false
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data is Slot:
		swap_slot(data)
		_anim_punch_effect()

func swap_slot(_target_slot: Slot) -> void:
	# swap the content (data) and update ui, the slot and icon always remains the same
	# apply effect to the target item in the slot here by checking the needed item type 
		# e.g. 	
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
	pass

func has_content() -> bool:
	return item != null

func _anim_punch_effect():
	self.scale = Vector2.ONE
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.07).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "set_scale").bind(Vector2.ONE))

func _on_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(icon, "scale", Vector2(1.5, 1.5), 0.07).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(icon, "scale", Vector2(1.2, 1.2), 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	if item: slot_focused.emit(item)

func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(icon, "scale", Vector2(1, 1), 0.07).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	slot_unfocused.emit()
