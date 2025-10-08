extends InteractionComponent
class_name InteractionButton

@onready var outline: MeshInstance3D = %Outline
var is_pressed: bool = false

func _ready() -> void:
	super._ready()
	outline.visible = false

func preInteract(_hand: Marker3D, _target: Node = null) -> void:
	super.preInteract(_hand, _target)
	if is_pressed: return
	is_pressed = true
	outline.visible = true
	notify_nodes(0)

func postInteract() -> void:
	if not is_pressed: return
	super.postInteract()
	is_pressed = false

func interact_hint() -> void:
	super.interact_hint()
	outline.visible = true

func disable_interact_hint() -> void:
	super.disable_interact_hint()
	outline.visible = false