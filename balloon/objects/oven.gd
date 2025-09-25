extends MeshInstance3D
class_name Oven

const MAX_FUEL: float = 100.0
var current_fuel: float = 0.0

var fule_conversion_rate: float = 0.9
var burning_rate: float = 1.0

@onready var fuel_bar: ProgressBar = %FuelBar
@onready var fuel_area: Area3D = $FuelArea
var objs_to_burn: Array[InteractionHolddable] = []
@onready var weight_label: Label = %WeightLabel
var total_weight : float

func _ready() -> void:
	if fuel_bar:
		fuel_bar.max_value = MAX_FUEL
		fuel_bar.value = current_fuel
	fuel_area.body_entered.connect(collect_fuel)
	fuel_area.body_exited.connect(remove_fuel)

func _process(delta: float) -> void:
	if current_fuel > 0.0:
		current_fuel = max(current_fuel - burning_rate * delta, 0.0)
	if fuel_bar:
		fuel_bar.value = current_fuel

func execute(_percentage: float) -> void:
	if randf() > 0.1: ## Horror feeling lol
		for obj in objs_to_burn:
			current_fuel = min(current_fuel + obj.fuel_amount * fule_conversion_rate, MAX_FUEL)
			obj.get_parent().call_deferred("queue_free")
		objs_to_burn.clear()
		total_weight = 0.0
		weight_label.text = "fuel me"

func get_fuel_percentage() -> float:
	return current_fuel / MAX_FUEL

func collect_fuel(body: Node3D) -> void:
	if body:
		var interaction_component = body.get_node_or_null("InteractionComponent") as InteractionHolddable
		if interaction_component and interaction_component not in objs_to_burn:
			objs_to_burn.append(interaction_component)
			total_weight += interaction_component.weight
			weight_label.text = "weights: " + str(total_weight)

func remove_fuel(body: Node3D) -> void:
	if body:
		var interaction_component = body.get_node_or_null("InteractionComponent") as InteractionHolddable
		if interaction_component and interaction_component in objs_to_burn:
			objs_to_burn.erase(interaction_component)
			
			if objs_to_burn.is_empty():
				total_weight = 0.0
				weight_label.text = "fuel me"
			else:
				total_weight -= interaction_component.weight
				weight_label.text = "weights: " + str(total_weight)
