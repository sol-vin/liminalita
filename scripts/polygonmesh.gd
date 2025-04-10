@tool
class_name PolygonMesh extends MeshInstance3D

@export_tool_button("Rebuild", "Callable") var rebuild_action = rebuild_face_data

@export_range(0.0, 2.0, 0.001) var normal_diff : float = 0.001
@export_range(0.0, 1000.0, 0.001) var vertex_diff : float = 0.001

@export var trans_material = preload("res://textures/trans.tres")
# TOOO: It may be better to make an array mesh and fill it with an array of vertices,
# This is because some faces may share vertex ids, and then when their color is changed
# it creates uneven colors. This can be fixed by making an arraymesh, and putting all vertexes and vertex colors in that instead.

#func _ready():
	#print("READY!")
	#rebuild_face_data()
	
func make_face(id : int, vertex_ids : Array[int]):
	return {"id" : id, "vertex_ids" : vertex_ids}
	
func make_polygon(face_ids : Array[int], vertex_ids : Array[int]):
	return {"face_ids" : face_ids, "vertex_ids" : vertex_ids}

## Colors vertexs for axis aligned and parallel faces
func rebuild_face_data():
	var mesh_data_surfaces = []
	var polygon_surfaces = []
	# Go through our surfaces to target each material, a material may show up multiple times
	var final_surface_id = 0
	for surface_id in mesh.get_surface_count():
		if get_active_material(surface_id).resource_path == trans_material.resource_path:
			#print("skipping trans material @ %s" % surface_id)
			continue
		var mesh_data = MeshDataTool.new()
		mesh_data_surfaces.push_back(mesh_data)
		#  Find the active surface material
		mesh_data.create_from_surface(mesh, surface_id)
		#print("Rebuilding surface %s -> %s! Vertexes: %s, Faces: %s" % [surface_id, final_surface_id, mesh_data.get_vertex_count(), mesh_data.get_face_count()])
		
		var normals = []
		var faces = {}
		
		# Go through each face
		for face_id in mesh_data.get_face_count():
			# Start sorting them into which faces align to which normals
			var normal = mesh_data.get_face_normal(face_id)
			
			# Find out if the normal we have is already in the normals, 
			# put it in if it isnt
			var normal_id = 0
			var found_normal_index = false
			
			# Seed the normals list
			if normals.is_empty():
				normals.push_back(normal)
				found_normal_index = true
			
			# Go through the normals we have so far
			for n_index in normals.size():
				# Check if it has the same normal
				if normals[n_index].is_equal_approx(normal) || (normals[n_index].distance_to(normal) < normal_diff):
					normal_id = n_index
					found_normal_index = true
					break
			
			# Add this normal as a unique normal`
			if !found_normal_index:
				normals.push_back(normal)
				normal_id = normals.size() - 1
			
			# Create normal entry in faces if needed, otherwise store
			var entry = make_face(face_id, [
					mesh_data.get_face_vertex(face_id, 0), 
					mesh_data.get_face_vertex(face_id, 1), 
					mesh_data.get_face_vertex(face_id, 2)
					])
			if faces.has(normal_id):
				# The list already exists so push our entry`
				faces[normal_id].push_back(entry)
			else:
				# Make a normals list and add this entry
				faces[normal_id] = [entry]
			
		#print(normals)
		#print(faces)
		
		var polygons := []
		# polygons[0] = {"faces" = [0, 1, 2], "vertices",[v1, v2, v3, etc..]}
		polygon_surfaces.push_back(polygons)
		
		# Go through normals list
		for normal_id in normals.size():
			# Copy the list of faces so we can remove them as we put them into polygons`
			var normal_faces = faces[normal_id].duplicate()
			
			# Go until all the faces have been exhausted`
			while !normal_faces.is_empty():
				# Grab a face
				var current_face = normal_faces.pop_back()
				
				# Push a new polygon entry
				polygons.push_back(make_polygon([], []))
				var polygon_id = polygons.size() - 1
				
				# List of faces we have found for this polygon
				var found_faces = [current_face]
				
				# Process any found faces
				while !found_faces.is_empty():
					# Add all found faces to our current polygon
					for face in found_faces:
						# Add the face id to the list
						polygons[polygon_id]["face_ids"].push_back(face["id"])
						# Add the vertices that aren't equal to another one
						for f_vertex in face["vertex_ids"]:
							var found_vertex = false
							for vertex in polygons[polygon_id]["vertex_ids"]:
								# Does the vertex id match?
								if vertex == f_vertex:
									found_vertex = true
									break
							if !found_vertex:
								polygons[polygon_id]["vertex_ids"].push_back(f_vertex)
					found_faces.clear()
					
					# Go through each face in the normal, duplicate it to make modifications
					for normal_face in normal_faces.duplicate():
						# Go through each normal_face's vertex id
						for nf_vertex in normal_face["vertex_ids"]:
							# Does nf_vertex have the same id as any of the polygon vertices?
							if polygons[polygon_id]["vertex_ids"].has(nf_vertex):
								found_faces.push_back(normal_face)
								normal_faces.erase(normal_face)
								break
							else:
								# Check if p_vertex is approx equal to nf_vertex
								for p_vertex in polygons[polygon_id]["vertex_ids"]:
									var nf_v3 = mesh_data.get_vertex(nf_vertex)
									var p_v3 = mesh_data.get_vertex(p_vertex)
									var v_distance = nf_v3.distance_to(p_v3)
									if nf_v3.is_equal_approx(p_v3) or v_distance < vertex_diff:
										found_faces.push_back(normal_face)
										normal_faces.erase(normal_face)
										break
								# Back out again if we found a face and we dont need to check the other vertexes
								if !found_faces.is_empty() and found_faces.back() == normal_face:
									break
						# If we didnt find a matching vertex on this face, we should also check the edges that are colinear
						if found_faces.is_empty() or (!found_faces.is_empty() and found_faces.back() != normal_face):
							# Do edge detection instead
							# Pick a face edge from the normal_face
							for nf_edge_idx in 3:
								var nf_edge_id = mesh_data.get_face_edge(normal_face["id"], nf_edge_idx)
								# Pick a face edge from polygon
								for p_face_id in polygons[polygon_id]["face_ids"]:
									for p_edge_idx in 3:
										var p_edge_id = mesh_data.get_face_edge(p_face_id, p_edge_idx)
											
										var nf_edge_vertex1_id = mesh_data.get_edge_vertex(nf_edge_id, 0)
										var nf_edge_vertex2_id = mesh_data.get_edge_vertex(nf_edge_id, 1)
										var nf_edge_vertex1 := mesh_data.get_vertex(nf_edge_vertex1_id)
										var nf_edge_vertex2 := mesh_data.get_vertex(nf_edge_vertex2_id)
										var nf_edge_direction = nf_edge_vertex1.direction_to(nf_edge_vertex2)
										
										var p_edge_vertex1_id = mesh_data.get_edge_vertex(p_edge_id, 0)
										var p_edge_vertex2_id = mesh_data.get_edge_vertex(p_edge_id, 1)
										var p_edge_vertex1 := mesh_data.get_vertex(p_edge_vertex1_id)
										var p_edge_vertex2 := mesh_data.get_vertex(p_edge_vertex2_id)
										var p_edge_direction1 = p_edge_vertex1.direction_to(p_edge_vertex2)
										var p_edge_direction2 = p_edge_vertex2.direction_to(p_edge_vertex1)
										# Check if the two edges have the same direction
										if nf_edge_direction.is_equal_approx(p_edge_direction1) || nf_edge_direction.is_equal_approx(p_edge_direction2):
											# Use one vertex from the normal face edge, and one from the polygon edge to make a new edge direction
											# If that new edge direction is equal to the polygon edge direction, it is colinear`
											var mixed_edge_direction = nf_edge_vertex1.direction_to(p_edge_vertex1)
											if mixed_edge_direction.is_equal_approx(p_edge_direction1) ||  mixed_edge_direction.is_equal_approx(p_edge_direction2):
												found_faces.push_back(normal_face)
												normal_faces.erase(normal_face)
												break
									# We found a face so break to go to the next normal face
									if !found_faces.is_empty() and found_faces.back() == normal_face:
										break
								# We found a face so break to go to the next normal face
								if !found_faces.is_empty() and found_faces.back() == normal_face:
									break
									
		final_surface_id += 1

	# Initialize the ArrayMesh.
	var new_mesh = ArrayMesh.new()
	
	final_surface_id = 0
	for surface_id in mesh.get_surface_count():
		if get_active_material(surface_id).resource_path == trans_material.resource_path:
			continue
		
		var mesh_data = mesh_data_surfaces[final_surface_id]
		var surface_tool = SurfaceTool.new()
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		
		for polygon_id in polygon_surfaces[final_surface_id].size():
			var color = Color(randf(), randf(), randf(), 1.0)
			surface_tool.set_color(color)
			for face in polygon_surfaces[final_surface_id][polygon_id]["face_ids"]:
				var v1 = mesh_data.get_vertex(mesh_data.get_face_vertex(face, 0))
				var v2 = mesh_data.get_vertex(mesh_data.get_face_vertex(face, 1))
				var v3 = mesh_data.get_vertex(mesh_data.get_face_vertex(face, 2))
				var v1_n = mesh_data.get_vertex_normal(mesh_data.get_face_vertex(face, 0))
				var v2_n = mesh_data.get_vertex_normal(mesh_data.get_face_vertex(face, 1))
				var v3_n = mesh_data.get_vertex_normal(mesh_data.get_face_vertex(face, 2))
				
				surface_tool.set_normal(v1_n)
				
				surface_tool.add_vertex(v1)
				surface_tool.set_normal(v2_n)
				surface_tool.add_vertex(v2)
				surface_tool.set_normal(v3_n)
				surface_tool.add_vertex(v3)
		surface_tool.commit(new_mesh)
		new_mesh.surface_set_material(final_surface_id, get_active_material(surface_id))
		final_surface_id += 1
	mesh = new_mesh
