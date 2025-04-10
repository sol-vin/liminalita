@tool
class_name CircleFrame extends Frame

@export var body_radius := 0.5:
	set(n_body_size):
		body_radius = n_body_size
		#rebuild()

@export var z_size = 0.125

@export var sides = 16

func add_scene():
	super()
	scene.get_node("Mask").texture = load("textures/circle.png")
	scene.get_node("Mask/Screen").queue_redraw()

func rebuild():
	body = AABB()
	body.size = Vector3(body_radius*2, body_radius*2, z_size)
	body.position = -body.size/2.0
	
	# Inner points
	var bl = body.position + body.size * Vector3(0, 0, 0) + Vector3(lip_size, lip_size, 0)
	var br = body.position + body.size * Vector3(1, 0, 0) + Vector3(-lip_size, lip_size, 0)
	var ul = body.position + body.size * Vector3(0, 1, 0) + Vector3(lip_size, -lip_size, 0)
	var ur = body.position + body.size * Vector3(1, 1, 0) + Vector3(-lip_size, -lip_size, 0)
	
	var blz = bl + Vector3(0, 0, body.size.z * z_depth)
	var brz = br + Vector3(0, 0, body.size.z * z_depth)
	var ulz = ul + Vector3(0, 0, body.size.z * z_depth)
	var urz = ur + Vector3(0, 0, body.size.z * z_depth)
	
	make_nodes(body.size)
	
	var mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var outer_points = []
	var inner_points = []
	
	var angle_inc = 2*PI/sides
	
	for side in sides:
		outer_points.push_back(
			Vector2(
				cos(side*angle_inc) * body_radius,
				sin(side*angle_inc) * body_radius
			)
		)
		
		inner_points.push_back(
			Vector2(
				cos(side*angle_inc) * (body_radius - lip_size*2),
				sin(side*angle_inc) * (body_radius - lip_size*2),
			)
		)
	surface_tool.set_color(Color(randf(), randf(), randf()))
	
	for vertex in sides:
		var v1 = outer_points[vertex]
		var v2 = Vector2()
		if vertex == sides-1:
			v2 = outer_points[0]
		else:
			v2 = outer_points[vertex+1]
		surface_tool.add_vertex(Vector3(v1.x, v1.y, z_size/2))
		surface_tool.add_vertex(Vector3(v2.x, v2.y, z_size/2))
		surface_tool.add_vertex(Vector3(0,0,z_size/2))
	
	for vertex in sides:
		var v1 = outer_points[vertex]
		var v2 = Vector2()
		if vertex == sides-1:
			v2 = outer_points[0]
		else:
			v2 = outer_points[vertex+1]
		surface_tool.set_color(Color(randf(), randf(), randf()))
		surface_tool.add_vertex(Vector3(v1.x, v1.y, z_size/2))
		surface_tool.add_vertex(Vector3(v2.x, v2.y, z_size/2))
		surface_tool.add_vertex(Vector3(v2.x, v2.y, -z_size/2))
		
		surface_tool.add_vertex(Vector3(v1.x, v1.y, z_size/2))
		surface_tool.add_vertex(Vector3(v2.x, v2.y, -z_size/2))
		surface_tool.add_vertex(Vector3(v1.x, v1.y, -z_size/2))
	
	surface_tool.set_color(Color(randf(), randf(), randf()))
	for vertex in sides:
		var ov1 = outer_points[vertex]
		var ov2 = Vector2()
		if vertex == sides-1:
			ov2 = outer_points[0]
		else:
			ov2 = outer_points[vertex+1]
		
		var iv1 = inner_points[vertex]
		var iv2 = Vector2()
		if vertex == sides-1:
			iv2 = inner_points[0]
		else:
			iv2 = inner_points[vertex+1]
		
		surface_tool.add_vertex(Vector3(ov1.x, ov1.y, -z_size/2))
		surface_tool.add_vertex(Vector3(ov2.x, ov2.y, -z_size/2))
		surface_tool.add_vertex(Vector3(iv1.x, iv1.y, -z_size/2))
		
		surface_tool.add_vertex(Vector3(iv1.x, iv1.y, -z_size/2))
		surface_tool.add_vertex(Vector3(ov2.x, ov2.y, -z_size/2))
		surface_tool.add_vertex(Vector3(iv2.x, iv2.y, -z_size/2))
	
	for vertex in sides:
		var v1 = inner_points[vertex]
		var v2 = Vector2()
		if vertex == sides-1:
			v2 = inner_points[0]
		else:
			v2 = inner_points[vertex+1]
		surface_tool.set_color(Color(randf(), randf(), randf()))
		surface_tool.add_vertex(Vector3(v1.x, v1.y, -z_size/2 + z_size * z_depth))
		surface_tool.add_vertex(Vector3(v2.x, v2.y, -z_size/2 + z_size * z_depth))
		surface_tool.add_vertex(Vector3(v1.x, v1.y, -z_size/2))
		
		surface_tool.add_vertex(Vector3(v2.x, v2.y, -z_size/2 + z_size * z_depth))
		surface_tool.add_vertex(Vector3(v2.x, v2.y, -z_size/2))
		surface_tool.add_vertex(Vector3(v1.x, v1.y, -z_size/2))
	
	for vertex in sides:
		var v1 = inner_points[vertex]
		var v2 = Vector2()
		if vertex == sides-1:
			v2 = inner_points[0]
		else:
			v2 = inner_points[vertex+1]
		surface_tool.add_vertex(Vector3(v1.x, v1.y, -z_size/2 + z_size * z_depth))
		surface_tool.add_vertex(Vector3(v2.x, v2.y, -z_size/2 + z_size * z_depth))
		surface_tool.add_vertex(Vector3(0, 0, -z_size/2 + z_size * z_depth))
	surface_tool.commit(mesh)
	
	frame_mesh.mesh = mesh
	frame_mesh.mesh.surface_set_material(0, material)

	remake()