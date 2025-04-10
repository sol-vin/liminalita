@tool
extends FuncGodotMap

func _ready():
	build_complete.connect(on_build_complete)
	#build_map()

func on_build_complete():
	#return
	
	var world_bench_holder = Node3D.new()
	world_bench_holder.name = "World Bench"
	add_child(world_bench_holder)
	world_bench_holder.owner = self.owner
	
	var world_bench = Bench.new()
	world_bench.name = "World Bench"
	world_bench_holder.add_child(world_bench)
	world_bench.owner = self.owner
	
	for child in get_children():
		# Put all the benches in the world bench and calculate their polygons
		if child is Bench:
			for bench_child in child.get_children():
				if bench_child is MeshInstance3D:
					var polygon_mesh : PolygonMesh = PolygonMesh.new()
					polygon_mesh.mesh = bench_child.mesh.duplicate()
					
					
					#polygon_mesh.skin = world_spawn_child.skin.duplicate()
					#polygon_mesh.set_surface_override_material(0, load("res://textures/black.tres"))
					
					world_bench.add_child(polygon_mesh)
					polygon_mesh.owner = self.owner
					polygon_mesh.rebuild_face_data()
					
					polygon_mesh.global_position = bench_child.global_position
					polygon_mesh.global_rotation = bench_child.global_rotation
					polygon_mesh.name = "polygon"
					polygon_mesh.layers = 8
				else:
					bench_child.reparent(world_bench)
					bench_child.owner = self.owner
			child.queue_free()
		# Calculate polygons for WorldSpawns
		elif child is Frame:
			var facing_mesh : MeshInstance3D
			var surface_id = 0
			for frame_child in child.get_children():
				if frame_child is MeshInstance3D:
					for frame_surface_id in frame_child.mesh.get_surface_count():
						if frame_child.mesh.surface_get_material(frame_surface_id).resource_path == "res://textures/frame.tres":
							facing_mesh = frame_child
							surface_id = frame_surface_id
							break
				if facing_mesh:
					break
			assert(facing_mesh, "Incoming Frame from trenchbroom did not have a facing material. Cannot determine rotation")
			var mesh_data := MeshDataTool.new()
			mesh_data.create_from_surface(facing_mesh.mesh, surface_id)
			var normal = mesh_data.get_face_normal(0)
			child.rotation.y = Vector2(-normal.x, normal.z).angle() + PI/2

			#print(facing_corners)
			var min_x = INF
			var max_x = -INF
			
			var min_z = INF
			var max_z = -INF
			
			for vertex in mesh_data.get_vertex_count():
				var v = mesh_data.get_vertex(vertex)
				min_x = min(min_x, v.x)
				max_x = max(max_x, v.x)
				min_z = min(min_z, v.z)
				max_z = max(max_z, v.z)
			
			var facing_aabb = facing_mesh.get_aabb()
			var top_aabb = Rect2(facing_aabb.position.x, facing_aabb.position.z, facing_aabb.size.x, facing_aabb.size.y)
			
			var front_1 =  Vector2(min_x, min_z)
			var front_2 =  Vector2(max_x, max_z)
			var angle : float = (front_1-front_2).angle()
			var hyp = front_1.distance_to(front_2)
			var x_length = abs(front_1.x - front_2.x)
			var adj_length = top_aabb.size.x - x_length
			var z_length = abs(adj_length/sin(angle))
			
			if child is CircleFrame:
				child.body_radius = hyp/2
				child.z_size = abs(z_length)
				if is_zero_approx(z_length):
					child.z_size = facing_aabb.size.z
				elif is_zero_approx(adj_length):
					child.z_size = facing_aabb.size.x
			elif child is RectangleFrame:
				if is_zero_approx(z_length):
					child.body_size = Vector3(hyp, facing_aabb.size.y, facing_aabb.size.z)
				else:
					child.body_size = Vector3(hyp, facing_aabb.size.y, z_length)

			
			facing_mesh.queue_free()
			
			if !child.linked_to_name.is_empty():
				var all_frames = get_tree().get_nodes_in_group("Frames")
				for frame in all_frames:
					if frame.name == child.name:
						continue
					if frame.name and frame.name == child.linked_to_name:
						child.linked_to = frame
						break
			child.rebuild()
		elif child is WorldSpawn:
			for world_spawn_child in child.get_children():
				if world_spawn_child is MeshInstance3D:
					var polygon_mesh : PolygonMesh = PolygonMesh.new()
					polygon_mesh.mesh = world_spawn_child.mesh.duplicate()
					#polygon_mesh.skin = world_spawn_child.skin.duplicate()
					#polygon_mesh.set_surface_override_material(0, world_spawn_child.get_surface_override_material(0))
					
					child.add_child(polygon_mesh)
					polygon_mesh.owner = self.owner
					#polygon_mesh.owner = self.owner
					#polygon_mesh.set_surface_override_material(0, load("res://textures/white.tres"))
					polygon_mesh.rebuild_face_data()
					polygon_mesh.name = "polygon"
					polygon_mesh.layers = world_spawn_child.layers
					world_spawn_child.queue_free()
	var left_click_action = BenchLeftClickAction.new()
	left_click_action.name = "LeftClickAction"
	world_bench.add_child(left_click_action)
	left_click_action.owner = self.owner

	for frame in get_tree().get_nodes_in_group("Frames"):
		frame.rebuild()
