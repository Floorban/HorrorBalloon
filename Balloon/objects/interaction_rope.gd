extends InteractionComponent
class_name InteractionRope

func _ready() -> void:
	super._ready()

func _input(event):
	if not is_interacting: return

	if event is InputEventMouseMotion:
		var delta: float = -event.relative.y * 0.001
		# Simulate resistance to small motions
		if abs(delta) < 0.01:
			delta *= 0.25
		# Smooth velocity blending
		print(delta)		

func preInteract(_hand: Marker3D, _target: Node = null) -> void:
	super.preInteract(_hand, _target) ## put it before the mode check otherwise can't be detected as is_interacting when hold_to_switch mode
	if not is_occupied:  										   
		is_occupied = true
