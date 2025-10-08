extends MeshInstance3D
class_name Oven

const MAX_FUEL: float = 100.0
var current_fuel: float = 0.0

var fule_conversion_rate: float = 1.0
var burning_rate : float
var defualt_burning_rate := 0.5
var cooling_rate := 8.0
var is_burning: bool

@onready var fuel_bar: ProgressBar = %FuelBar
@onready var fuel_area: Area3D = $FuelArea
var objs_to_burn: Array[InteractionComponent] = []
@onready var weight_label: Label = %WeightLabel
var total_weight : float

## -- Sound Settings --
@export var SFX_Fire: String
@export var SFX_Release: String
var i_Fire: FmodEvent = null

## -- Particle Settings -- 
@onready var flame: GPUParticles3D = $Flame
@onready var flame2: GPUParticles3D = $Flame2
@onready var smoke: GPUParticles3D = $Smoke

var balloon : BalloonController

func _ready() -> void:
	var b = get_parent().get_parent()
	if b is BalloonController: balloon = b
	smoke.emitting = false

	if fuel_bar:
		fuel_bar.max_value = MAX_FUEL
		fuel_bar.value = current_fuel
	fuel_area.body_entered.connect(collect_fuel)
	fuel_area.body_exited.connect(remove_fuel)

	burning_rate = defualt_burning_rate

func _process(_delta: float) -> void:
	if current_fuel > 0.0:
			flame.emitting = true
			flame2.emitting = true
			if !is_burning:
				i_Fire = Audio.play_instance(SFX_Fire, global_transform)
				is_burning = true
			# current_fuel = max(current_fuel - burning_rate * delta, 0.0)
	else:
		flame.emitting = false
		flame2.emitting = false
		smoke.emitting = false
		Audio.clear_instance(i_Fire)
		is_burning = false
	
	if fuel_bar:
		fuel_bar.value = current_fuel

func execute(_percentage: float) -> void:
	## for cooling
	if _percentage >= 0.99:
		burning_rate = cooling_rate
		Audio.play(SFX_Release, global_transform)
		smoke.emitting = true
	else:
		smoke.emitting = false
		burning_rate = defualt_burning_rate
		if _percentage <= 0.0:
			for obj in objs_to_burn:
				current_fuel = min(current_fuel + obj.fuel_amount * fule_conversion_rate, MAX_FUEL)
				if balloon and balloon.objs_in_balloon.has(obj.object_ref):
					balloon._on_body_exited(obj.object_ref)
					#balloon.objs_in_balloon.erase(obj.object_ref)
				obj.get_parent().call_deferred("queue_free")
			objs_to_burn.clear()
			total_weight = 0.0
			weight_label.text = "fuel me"

func get_fuel_percentage() -> float:
	return current_fuel / MAX_FUEL

func consume_fuel(amount: float) -> void:
	current_fuel = max(current_fuel - amount * burning_rate, 0.0)

func collect_fuel(body: Node3D) -> void:
	if body is RigidBody3D or body is CharacterBody3D:
		var interaction_component = body.get_node_or_null("InteractionComponent")
		if interaction_component and "weight" in interaction_component and interaction_component not in objs_to_burn:
			#body.linear_velocity = Vector3.ZERO
			objs_to_burn.append(interaction_component)
			total_weight += interaction_component.weight
			weight_label.text = "weights: " + str(total_weight)

func remove_fuel(body: Node3D) -> void:
	if body:
		var interaction_component = body.get_node_or_null("InteractionComponent")
		if interaction_component and interaction_component in objs_to_burn:
			objs_to_burn.erase(interaction_component)
			
			if objs_to_burn.is_empty():
				total_weight = 0.0
				weight_label.text = "fuel me"
			else:
				total_weight -= interaction_component.weight
				weight_label.text = "weights: " + str(total_weight)
