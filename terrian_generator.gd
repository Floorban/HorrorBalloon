@tool
extends MeshInstance3D
class_name TerrianGeneration

@export var x_size = 200
@export var z_size = 200
@export var height = 5
@export var noise = 0.5

@export var min_height := 0.0
@export var max_height := 1.0

@export var update = false
@export var clear_vert_vis = false

@export var generate: bool = false:
	set(value):
		update = value
		if Engine.is_editor_hint() and value:
			_on_generate_preview_pressed()
			update = false
			generate = false

func _on_generate_preview_pressed():
	if x_size <= 0 or z_size <= 0:
		push_warning("Spawn point container not found.")
		return
	randomize()
	generate_terrian()

func _ready() -> void:
	pass

func generate_terrian() -> void:
	var a_mesh: ArrayMesh
	var surf_tool =  SurfaceTool.new()
	var n = FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_PERLIN
	n.frequency = 0.1
	surf_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for z in range(z_size + 1):
		for x in range(x_size + 1):
			var y = n.get_noise_2d(x*noise,z*noise) * height
			if y < min_height and y != null:
				min_height = y
			if y > max_height and y != null:
				max_height = y
			
			var uv = Vector2()
			uv.x = inverse_lerp(0,x_size,x)
			uv.y = inverse_lerp(0,z_size,z)
			surf_tool.set_uv(uv)
			surf_tool.add_vertex(Vector3(x,y,z))
			draw_dots(Vector3(x,y,z))
	
	var vert = 0
	for z in z_size:
		for x in x_size:
			surf_tool.add_index(vert+0)
			surf_tool.add_index(vert+1)
			surf_tool.add_index(vert+x_size+1)
			surf_tool.add_index(vert+x_size+1)
			surf_tool.add_index(vert+1)
			surf_tool.add_index(vert+x_size+2)
			vert += 1
	
	surf_tool.generate_normals()
	a_mesh = surf_tool.commit()
	mesh = a_mesh
	update_shader()

func update_shader() -> void:
	var mat = get_active_material(0) as ShaderMaterial
	mat.set_shader_parameter("min_height", min_height)
	mat.set_shader_parameter("max_height", max_height)

func draw_dots(pos:Vector3) -> void:
	var ins = MeshInstance3D.new()
	add_child(ins)
	ins.position = pos
	var dot = SphereMesh.new()
	dot.radius = 0.1
	dot.height = 0.2
	ins.mesh = dot

func _process(_delta: float) -> void:
	if clear_vert_vis:
		for i in get_children():
			i.free()
