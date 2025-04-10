@tool
class_name RectangleFrame extends Frame

@export var body_size := Vector3(1.0, 1.0, 0.125):
	set(n_body_size):
		body_size = n_body_size
		#rebuild()

func rebuild():
	body = AABB()
	body.size = body_size
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
	
	make_nodes(body_size)
	
	var mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Back polygon
	surface_tool.set_color(Color(randf(), randf(), randf()))
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 0, 1)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 1, 1)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 1, 1)))
	
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 0, 1)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 0, 1)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 1, 1)))
	
	# Bottom polygon
	surface_tool.set_color(Color(randf(), randf(), randf()))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 0, 1)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 0, 0)))
	surface_tool.add_vertex(body.position)
	
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 0, 1)))
	surface_tool.add_vertex(body.position)
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 0, 1)))
	
	# Top Polygon
	surface_tool.set_color(Color(randf(), randf(), randf()))
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 1, 0)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 1, 0)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 1, 1)))
	
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 1, 1)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 1, 1)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 1, 0)))
	
	# Left polygon
	surface_tool.set_color(Color(randf(), randf(), randf()))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 1, 1)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 1, 0)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 0, 0)))
	
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 1, 1)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 0, 0)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 0, 1)))
	
	# Right polygon
	surface_tool.set_color(Color(randf(), randf(), randf()))
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 0, 0)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 1, 0)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 1, 1)))
	
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 0, 1)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 0, 0)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 1, 1)))
	
	# Front lip polygon
	surface_tool.set_color(Color(randf(), randf(), randf()))
	
	# Right Side
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 1, 0)))
	surface_tool.add_vertex(body.position)
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 0, 0)) + Vector3(lip_size, 0, 0))
	
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 0, 0)) + Vector3(lip_size, 0, 0))
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 1, 0)) + Vector3(lip_size, 0, 0))
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 1, 0)))
	
	# Left Side
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 0, 0)) - Vector3(lip_size, 0, 0))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 0, 0)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 1, 0)))
	
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 0, 0)) - Vector3(lip_size, 0, 0))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 1, 0)))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 1, 0)) - Vector3(lip_size, 0, 0))
	
	# Bottom polygon
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 0, 0)) + Vector3(lip_size, 0, 0))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 0, 0)) + Vector3(-lip_size, 0, 0))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 0, 0)) + Vector3(-lip_size, lip_size, 0))
	
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 0, 0)) + Vector3(lip_size, lip_size, 0))
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 0, 0)) + Vector3(lip_size, 0, 0))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 0, 0)) + Vector3(-lip_size, lip_size, 0))
	

	# Top polygon
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 1, 0)) + Vector3(-lip_size, -lip_size, 0))
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 1, 0)) + Vector3(-lip_size, 0, 0))
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 1, 0)) + Vector3(lip_size, 0, 0))
	
	surface_tool.add_vertex(body.position + (body.size * Vector3(1, 1, 0)) + Vector3(-lip_size, -lip_size, 0))
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 1, 0)) + Vector3(lip_size, 0, 0))
	surface_tool.add_vertex(body.position + (body.size * Vector3(0, 1, 0)) + Vector3(lip_size, -lip_size, 0))
	
	# Inner wall top
	surface_tool.set_color(Color(randf(), randf(), randf()))
	surface_tool.add_vertex(bl)
	surface_tool.add_vertex(br)
	surface_tool.add_vertex(brz)
	
	surface_tool.add_vertex(bl)
	surface_tool.add_vertex(brz)
	surface_tool.add_vertex(blz)
	
	# Inner wall bottom
	surface_tool.set_color(Color(randf(), randf(), randf()))
	surface_tool.add_vertex(urz)
	surface_tool.add_vertex(ur)
	surface_tool.add_vertex(ul)
	
	surface_tool.add_vertex(ulz)
	surface_tool.add_vertex(urz)
	surface_tool.add_vertex(ul)
	
	# Inner wall left
	surface_tool.set_color(Color(randf(), randf(), randf()))
	surface_tool.add_vertex(ul)
	surface_tool.add_vertex(bl)
	surface_tool.add_vertex(ulz)
	
	surface_tool.add_vertex(blz)
	surface_tool.add_vertex(ulz)
	surface_tool.add_vertex(bl)
	
	# Inner wall left
	surface_tool.set_color(Color(randf(), randf(), randf()))
	surface_tool.add_vertex(urz)
	surface_tool.add_vertex(br)
	surface_tool.add_vertex(ur)
	
	surface_tool.add_vertex(br)
	surface_tool.add_vertex(urz)
	surface_tool.add_vertex(brz)
	
	# Inset back
	
	surface_tool.set_color(Color(randf(), randf(), randf()))
	
	surface_tool.add_vertex(blz)
	surface_tool.add_vertex(urz)
	surface_tool.add_vertex(ulz)
	
	surface_tool.add_vertex(blz)
	surface_tool.add_vertex(brz)
	surface_tool.add_vertex(urz)
	
	surface_tool.commit(mesh)
	
	frame_mesh.mesh = mesh
	frame_mesh.mesh.surface_set_material(0, material)

	remake()
