@tool
extends MeshInstance3D
class_name TerrianGeneration


@export_range(20,400, 1) var Terrain_Size := 100
@export_range(1, 100, 1) var resolution := 30

const center_offset := 0.5
@export var Terrain_Max_Height = 5
@export var noise_offset = 0.5
@export var noise:FastNoiseLite = FastNoiseLite.new()
@export var create_collision = false
@export var remove_collision = false
@export var clear_vert_vis = false

var min_height := 0.0
var max_height := 1.0

var last_res = 0
var last_size = 0
var last_height = 0
var last_offset = 0

@export var generate: bool = false:
	set(value):
		if Engine.is_editor_hint() and value:
			_on_generate_preview_pressed()
			generate = false

func _on_generate_preview_pressed():
	randomize()
	generate_terrain()

func _ready():
	generate_terrain()

func _process(_delta):
	if resolution!=last_res or Terrain_Size!=last_size or \
		Terrain_Max_Height!=last_height or noise_offset!=last_offset:
		generate_terrain()
		last_res = resolution
		last_size = Terrain_Size
		last_height = Terrain_Max_Height
		last_offset = noise_offset
	
	if remove_collision:
		clear_collision()
		remove_collision = false
	if create_collision:
		create_trimesh_collision()
		create_collision = false
	
	if clear_vert_vis:
		for i in get_children():
			i.free()

func generate_terrain():
	var a_mesh = ArrayMesh.new()
	var surftool = SurfaceTool.new()
	
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	surftool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for z in resolution+1:
		for x in resolution+1:
			var percent = Vector2(x,z)/resolution
			var pointOnMesh = Vector3((percent.x-center_offset),0,(percent.y-center_offset))
			var vertex = pointOnMesh * Terrain_Size;
			vertex.y = noise.get_noise_2d(vertex.x*noise_offset,vertex.z*noise_offset) * Terrain_Max_Height
			var uv = Vector2()
			uv.x = percent.x
			uv.y = percent.y
			surftool.set_uv(uv)
			surftool.add_vertex(vertex)
	var vert = 0
	for z in resolution:
		for x in resolution:
			surftool.add_index(vert+0)
			surftool.add_index(vert+1)
			surftool.add_index(vert+resolution+1)
			surftool.add_index(vert+resolution+1)
			surftool.add_index(vert+1)
			surftool.add_index(vert+resolution+2)
			vert+=1
		vert+=1
	surftool.generate_normals()
	a_mesh = surftool.commit()

	mesh = a_mesh
	
	generate_collision()
	update_shader()

func generate_collision():
	clear_collision()
	create_trimesh_collision()
	var static_body = get_child(0) as StaticBody3D
	if static_body: static_body.set_collision_layer_value(32,true)

func clear_collision():
	if get_child_count() > 0:
		for i in get_children():
			i.free()

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
