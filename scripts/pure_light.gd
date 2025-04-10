@tool

class_name PureLight extends OmniLight3D

@export_tool_button("Reset", "Callable") var reset_action = reset
@export_color_no_alpha var color = Color(0, 0, 0):
	set(n_color):
		color = n_color
		if !color_is_black && !color_is_white:
			n_color.h = n_color.h + 0.5
			n_color.s = 1.0
			n_color.v = 1.0
			
		if color_is_black:
			n_color.h = 0.0
			n_color.s = 0.0
			n_color.v = n_color.v + 0.5
		
		if color_is_white:
			n_color.h = 0.0
			n_color.s = 0.0
			n_color.v = n_color.v
		n_color.a = 1.0
		light_color = n_color
		
@export var color_is_black = false:
	set(n_color_is_black):
		color_is_black = n_color_is_black
		color = color
		
		if color_is_black:
			light_negative = true
			color_is_white = false

@export var color_is_white = false:
	set(n_color_is_white):
		color_is_white = n_color_is_white
		color = color
		
		if color_is_white:
			light_negative = false
			color_is_black = false
		if !color_is_white:
			light_negative = true
			


func _func_godot_apply_properties(props: Dictionary) -> void:
	reset()
	if props.has("color"):
		self.color = Color.from_hsv(props["color"], 1.0, 1.0)
	if props.has("energy"):
		self.light_energy = props["energy"]
	if props.has("range"):
		self.omni_range = props["range"]
	if props.has("attenuation"):
		self.omni_attenuation = props["attenuation"]
	if props.has("color_is_black"):
		self.color_is_black = props["color_is_black"]
	if props.has("color_is_white"):
		self.color_is_white = props["color_is_white"]

func reset() -> void:
	light_negative = true
	light_indirect_energy = 0
	light_volumetric_fog_energy = 0
	light_specular = 0
	light_energy = 0.5
	omni_range = 10.0
	omni_attenuation = 0
	light_bake_mode = Light3D.BAKE_DISABLED
	shadow_enabled = true
	shadow_blur = 1.0
	light_cull_mask = 1 + (1<<2) + (1<<4)
	shadow_caster_mask = 1 + (1<<2)
	light_bake_mode = BakeMode.BAKE_STATIC
	
