extends MeshInstance3D
class_name Oven

const MAX_FUEL: float = 100.0
var current_fuel: float = 0.0

var fule_conversion_rate: float = 0.8
var burning_rate: float = 5.0

@onready var fuel_area: Area3D = $FuelArea
var objs_to_burn: Array[InteractionHolddable] = []

func _ready() -> void:
	fuel_area.body_entered.connect(collect_fuel)
	fuel_area.body_exited.connect(remove_fuel)

func _process(delta: float) -> void:
	if current_fuel > 0.0:
		current_fuel = max(current_fuel - burning_rate * delta, 0.0)

func execute(_percentage: float) -> void:
	print("execute called on:", self.name)
	print("objs_to_burn:", objs_to_burn)
	for obj in objs_to_burn:
		print("adding fuel!")
		current_fuel = min(current_fuel + obj.fuel_amount * fule_conversion_rate, MAX_FUEL)
		obj.get_parent().queue_free()
		objs_to_burn.erase(obj)
	objs_to_burn.clear()

func get_fuel_percentage() -> float:
	return current_fuel / MAX_FUEL

func collect_fuel(body: Node3D) -> void:
	if body:
		var interaction_component = body.get_node_or_null("InteractionComponent") as InteractionHolddable
		if interaction_component and interaction_component not in objs_to_burn:
			objs_to_burn.append(interaction_component)

func remove_fuel(body: Node3D) -> void:
	if body:
		var interaction_component = body.get_node_or_null("InteractionComponent") as InteractionHolddable
		if interaction_component and interaction_component in objs_to_burn:
			objs_to_burn.erase(interaction_component)
