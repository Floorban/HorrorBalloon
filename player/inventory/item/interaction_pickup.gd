extends InteractionComponent
class_name InteractionPickup

@onready var mesh_instance = %MeshInstance
@export var item_data : ItemData

func _ready() -> void:
	object_ref.name = item_data.item_name
	spawn_mesh_with_col(item_data.mesh_scene)

func preInteract(hand: Marker3D, target: Node = null) -> void:
	super.preInteract(hand, target)
	_pickup_interact()

func _pickup_interact():
	if ItemInventory.add_item(item_data):
		call_deferred("queue_free")
	else:
		print("inventory is fulll")

func find_mesh(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var result = find_mesh(child)
		if result: return result
	return null

func spawn_mesh_with_col(scene : PackedScene) -> Node3D:
	var inst = scene.instantiate()
	var mesh_instance = find_mesh(inst)
	if mesh_instance and mesh_instance.mesh:
		var shape = mesh_instance.mesh.create_convex_shape()
		var col = CollisionShape3D.new()
		col.shape = shape
		object_ref.add_child.call_deferred(inst)
		object_ref.add_child.call_deferred(col)
	return inst
