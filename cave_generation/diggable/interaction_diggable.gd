extends InteractionComponent
class_name InteractionDiggable

var ore_instance : OreInstance
var ore_data : OreData

func _ready():
	ore_instance = object_ref as OreInstance
	ore_data = ore_instance.ore_data

func preInteract(hand: Marker3D, target: Node = null) -> void:
	super.preInteract(hand, target)
	_diggable_interact()

func _diggable_interact():
	pass
