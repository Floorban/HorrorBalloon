extends MeshInstance3D
class_name Oven

const MAX_FUEL: float = 100.0
var current_fuel: float = 0.0

var fule_conversion_rate: float = 1.0
var burning_rate : float
var defualt_burning_rate := 0.5
var cooling_rate := 10.0

@onready var fuel_bar: ProgressBar = %FuelBar
@onready var fuel_area: Area3D = $FuelArea
var objs_to_burn: Array[InteractionComponent] = []
@onready var weight_label: Label = %WeightLabel
var total_weight : float

var audio: AudioManager
var e_flame: FmodEventEmitter3D
var e_flame_is_playing: bool
@onready var e_release: FmodEventEmitter3D = $Audio/SFX_ReleaseGas
@onready var flame: GPUParticles3D = $Flame
@onready var flame2: GPUParticles3D = $Flame2
@onready var smoke: GPUParticles3D = $Smoke

func _ready() -> void:
	smoke.emitting = false
	audio = get_tree().get_first_node_in_group("audio")
	e_flame = audio.cache(get_node("Audio/SFX_Flame"), global_position)

	if fuel_bar:
		fuel_bar.max_value = MAX_FUEL
		fuel_bar.value = current_fuel
	fuel_area.body_entered.connect(collect_fuel)
	fuel_area.body_exited.connect(remove_fuel)

	burning_rate = defualt_burning_rate

func _process(delta: float) -> void:
	if current_fuel > 0.0:
			flame.emitting = true
			flame2.emitting = true
			if !e_flame_is_playing:
				e_flame.paused = false
				e_flame_is_playing = true
			current_fuel = max(current_fuel - burning_rate * delta, 0.0)
	else:
		flame.emitting = false
		flame2.emitting = false
		smoke.emitting = false
		e_flame_is_playing = false
		e_flame.paused = true
	
	if fuel_bar:
		fuel_bar.value = current_fuel

func execute(_percentage: float) -> void:
	## for cooling
	if _percentage >= 0.99:
		burning_rate = cooling_rate
		e_release.play_one_shot()
		smoke.emitting = true
	else:
		smoke.emitting = false
		burning_rate = defualt_burning_rate
		if _percentage <= 0.0 and randf() > 0.1: ## Horror feeling lol
			for obj in objs_to_burn:
				current_fuel = min(current_fuel + obj.fuel_amount * fule_conversion_rate, MAX_FUEL)
				obj.get_parent().call_deferred("queue_free")
			objs_to_burn.clear()
			total_weight = 0.0
			weight_label.text = "fuel me"

func get_fuel_percentage() -> float:
	return current_fuel / MAX_FUEL

func collect_fuel(body: Node3D) -> void:
	if body is RigidBody3D:
		var interaction_component = body.get_node_or_null("InteractionComponent")
		if interaction_component and "weight" in interaction_component and interaction_component not in objs_to_burn:
			body.linear_velocity = Vector3.ZERO
			print("Ss")
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

func _exit_tree() -> void:
	e_flame.queue_free()
