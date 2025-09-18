class_name PlayerController
extends CharacterBody3D

signal interact_obj
@onready var interaction_ray: RayCast3D = $Head/Camera3D/RayCast3D

@onready var carry_obj_marker: Marker3D = $CarryObjMarker
var carried_obj : Interactable

@onready var camera: Camera3D = $Head/Camera3D
@onready var camera_controller_anchor: Marker3D = $CamAnchor

func _physics_process(_delta: float) -> void:
	# WASD movement vector
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# super basic locomotion
	var new_velocity = Vector2.ZERO
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	if direction:
		new_velocity = Vector2(direction.x, direction.z) * 0.5
	velocity = Vector3(new_velocity.x, velocity.y, new_velocity.y)
	move_and_slide()

func _process(_delta: float) -> void:
	_check_interactable(interaction_ray)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interaction") and carried_obj:
		carried_obj.reparent(get_tree().get_first_node_in_group("balloon"))
		carried_obj = null

func _check_interactable(ray: RayCast3D):
	if ray.is_colliding():
		var collider = ray.get_collider()
		interact_obj.emit(collider)
	else:
		interact_obj.emit(null)

func pick_up_obj(obj):
	obj.reparent(self)
	obj.global_rotation = self.rotation
	obj.global_position = carry_obj_marker.global_position
	
	await get_tree().create_timer(.1).timeout
	carried_obj = obj

func apply_sway(tilt: Vector3):
	var sway = Vector3(-tilt.x * 0.7, 0.0, -tilt.z * 0.7)
	camera.rotation = camera.rotation.lerp(sway, 0.1)