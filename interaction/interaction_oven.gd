extends InteractionComponent

func preInteract(_hand: Marker3D, _target: Node = null) -> void:
	super.preInteract(_hand, _target)
	notify_nodes(1)

func postInteract() -> void:
	super.postInteract()
	notify_nodes(0.5)
