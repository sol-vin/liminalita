@tool
class_name Frame extends Node3D

@export var seed = false:
	set(n_seed):
		seed = n_seed
		#rebuild()
@export var seed_value = 0:
	set(n_seed):
		seed_value = n_seed
		#rebuild()
@export var packed_scene : PackedScene = load("res://proc_art/test.tscn"):
	set(n_scene):
		packed_scene = n_scene
		#rebuild()

@export var update_mode : SubViewport.UpdateMode = SubViewport.UpdateMode.UPDATE_ONCE:
	set(n_update_mode):
		update_mode = n_update_mode

@export_tool_button("Rebuild Mesh", "CSGBox3D") var rebuild_action = rebuild
		
@export_range(0.01, 0.5, 0.001) var lip_size = 0.1:
	set(n_lip_size):
		lip_size = n_lip_size
		#rebuild()
		
@export_range(0, 0.99, 0.0001) var z_depth = 0.25:
	set(n_z_depth):
		z_depth = n_z_depth
		#rebuild()

@export var material : Material = load("res://textures/grey.tres"):
	set(n_material):
		material = n_material
		#rebuild()

@export var screen_scale := Vector2(1, 1):
	set(n_scale):
		screen_scale = n_scale
		#rebuild()
		
@export var screen_meter_to_pixel : Vector2i = Vector2i(128, 128):
	set(n_screen_meter_to_pixel):
		screen_meter_to_pixel = n_screen_meter_to_pixel
		#rebuild()
@export var flip_screen_v = false

@export var linked_to_name : String = ""

var linked_to : Frame
		
#var material = screen_mesh.get_active_material(0)
#if linked_to:
	#material.albedo_texture = linked_to.scene_container.get_texture()
#else:
	#material.albedo_texture = scene_container.get_texture()
#screen_mesh.mesh.surface_set_material(0, material)
	#

var screen_size := Vector2(1, 1)
var body : AABB = AABB()

@export var frame_mesh : MeshInstance3D
@export var screen_mesh : MeshInstance3D
@export var screen_material := StandardMaterial3D.new()
@export var scene_container : SubViewport
@export var scene : Control
@export var occluder : OccluderInstance3D

static var proc_arts = load("res://proc_art/list.tres")

static var facing_material = load("res://textures/frame.tres")

func _enter_tree() -> void:
	add_to_group("Frames")

func _ready() -> void:
	remake()
	
func _func_godot_apply_properties(props: Dictionary) -> void:
	if props.has("name"):
		self.name = props["name"]
	if props.has("linked_to"):
		linked_to_name = props.linked_to
	if props.has("seed") and props["seed"] and props.has("seed_value"):
		seed = true
		seed_value = props["seed_value"]
	if props.has("packed_scene"):
		packed_scene = proc_arts.list[props["packed_scene"]]
	if props.has("lip_size"):
		lip_size = props["lip_size"]
	if props.has("z_depth"):
		z_depth = props["z_depth"]
	if props.has("screen_scale"):
		screen_scale = props["screen_scale"]
		if props.has("flip_screen_v"):
			flip_screen_v = props["flip_screen_v"]
	if props.has("screen_meter_to_pixel"):
		if props["screen_meter_to_pixel"] is Vector2i:
			screen_meter_to_pixel = props["screen_meter_to_pixel"]
		else:
			var split = props["screen_meter_to_pixel"].split(" ")
			screen_meter_to_pixel = Vector2i(
				int(split[0]),
				int(split[1])
			)


func remake():
	if scene:
		scene.queue_free()
	
	screen_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	screen_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen_material.disable_receive_shadows = true
	screen_material.disable_ambient_light = true
	screen_material.disable_fog = true
	screen_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

	if !linked_to_name.is_empty():
		for frame in get_tree().get_nodes_in_group("Frames"):
			if frame.name == linked_to_name:
				linked_to = frame


	if linked_to:
			screen_material.albedo_texture = linked_to.scene_container.get_texture()
	elif linked_to_name.is_empty() and screen_mesh:
		scene_container.size = Vector2i(screen_mesh.mesh.size * Vector2(screen_meter_to_pixel.x, screen_meter_to_pixel.y))	
		screen_material.albedo_texture = scene_container.get_texture()
		add_scene()
		scene.get_node("Mask/Screen").queue_redraw()
		
func add_scene():
		scene = packed_scene.instantiate()
		scene.name = "%s" % randi()
		if seed:
			scene.get_node("Mask/Screen").seed = true
			scene.get_node("Mask/Screen").seed_value = seed_value
		scene_container.add_child(scene)
		scene_container.render_target_update_mode = SubViewport.UPDATE_ONCE
		scene.owner = self.owner

func make_nodes(body_size):
	body = AABB()
	body.size = Vector3(1.0, 1.0, 1.0) * body_size
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
	
	if !occluder:
		occluder = OccluderInstance3D.new()
		occluder.name = "Occluder"
		add_child(occluder)
		occluder.owner = self.owner
	occluder.occluder = BoxOccluder3D.new()
	occluder.occluder.size = body.size
	#occluder.name = "Occluder"
	
	if !linked_to_name.is_empty():
		if scene_container:
			scene_container.queue_free()
			scene_container = null
	elif !scene_container:
		scene_container = SubViewport.new()
		scene_container.name = "Scene"
		add_child(scene_container)
		scene_container.owner = self.owner
		scene_container.render_target_update_mode = SubViewport.UPDATE_ONCE
		scene_container.own_world_3d = true
		scene_container.transparent_bg = true
		scene_container.gui_disable_input = true
	
	if !screen_mesh:
		screen_mesh = MeshInstance3D.new()
		screen_mesh.name = "Screen Mesh"
		add_child(screen_mesh)
		screen_mesh.owner = self.owner
	
	screen_mesh.mesh = QuadMesh.new()
	screen_mesh.mesh.flip_faces = true
	var vertex_size = (ulz-brz).abs()
	screen_size = Vector2(vertex_size.x, vertex_size.y) * screen_scale
	screen_mesh.mesh.size = screen_size
	screen_mesh.position.z = blz.z - 0.01
	screen_mesh.layers = 8
	screen_mesh.mesh.surface_set_material(0, screen_material)
	if flip_screen_v:
		screen_mesh.rotation.z = PI

	if !frame_mesh:
		frame_mesh = MeshInstance3D.new()
		frame_mesh.name = "Frame Mesh"
		add_child(frame_mesh)
		frame_mesh.owner = self.owner
		frame_mesh.layers = 8

func rebuild():
	pass
