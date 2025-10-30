extends Control
class_name SlotManager

var dragging_slot : Slot
var drag_offset := Vector2.ZERO
func _ready() -> void:
	drag_offset = Global.UI_DRAG_OFFSET

func _process(_datadelta: float) -> void:
	if Input.get_current_cursor_shape() == CURSOR_FORBIDDEN:
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
		
func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_DRAG_BEGIN:
		dragging_slot = get_viewport().gui_get_drag_data()
	if what == Node.NOTIFICATION_DRAG_END:
		# when end drag outside any slots
		if dragging_slot:
			if not is_drag_successful():
				var tween = create_tween()
				var target_pos = dragging_slot.global_position
				var slot_modulate = dragging_slot.self_modulate
				dragging_slot.self_modulate = Color.TRANSPARENT
				dragging_slot.icon.show()
				dragging_slot.global_position = get_global_mouse_position() + drag_offset
				tween.tween_property(dragging_slot, "global_position", target_pos, 0.03).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				tween.tween_callback(Callable(dragging_slot, "set").bind("self_modulate", slot_modulate))
				dragging_slot = null
			else:
				print("ss")
