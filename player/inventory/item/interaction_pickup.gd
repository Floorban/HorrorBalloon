extends InteractionComponent
class_name InteractionPickup

@export var item_data : ItemData

func _ready() -> void:
	Global.game_start.connect(unfreeze_obj)
	object_ref.name = item_data.item_name
	spawn_mesh_with_col(item_data.mesh_scene)

func _input(event: InputEvent) -> void:
	if not can_interact:
		
		return 
	if event.is_action_pressed("pickup"):
		_pickup_interact()

func _pickup_interact():
	if ItemInventory.add_item(item_data):
		object_ref.call_deferred("queue_free")
	else:
		print("inventory is fulll")

func find_mesh(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var result = find_mesh(child)
		if result: return result
	return null

func spawn_mesh_with_col(scene) -> Node3D:
	var inst = scene.instantiate()
	var mesh_instance = find_mesh(inst)
	if mesh_instance and mesh_instance.mesh:
		var shape = mesh_instance.mesh.create_convex_shape()
		var col = CollisionShape3D.new()
		col.shape = shape
		object_ref.add_child.call_deferred(inst)
		object_ref.add_child.call_deferred(col)
	return inst

func unfreeze_obj():
	if object_ref is RigidBody3D:
		object_ref.freeze = false
