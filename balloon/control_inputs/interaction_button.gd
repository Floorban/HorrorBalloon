extends InteractionComponent
class_name InteractionButton

@onready var mesh: MeshInstance3D = %Mesh
var mat: StandardMaterial3D
var is_pressed: bool = false
@export var direction := 1.0

func _ready() -> void:
	super._ready()
	mat = StandardMaterial3D.new()
	mat.albedo_color = Color.BLACK
	mesh.set_surface_override_material(0, mat)
	mat = mesh.get_surface_override_material(0) as StandardMaterial3D

func preInteract(_hand: Marker3D, _target: Node = null) -> void:
	super.preInteract(_hand, _target)
	if is_pressed: return
	is_pressed = true
	mat.albedo_color = Color.LIGHT_GRAY

func interact() -> void:
	if not is_pressed: return
	super.interact()
	notify_nodes(direction)

func postInteract() -> void:
	if not is_pressed: return
	super.postInteract()
	is_pressed = false
	notify_nodes(0)

func interact_hint() -> void:
	super.interact_hint()
	mat.albedo_color = Color.GRAY

func disable_interact_hint() -> void:
	super.disable_interact_hint()
	mat.albedo_color = Color.BLACK