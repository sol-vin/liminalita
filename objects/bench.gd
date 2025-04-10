class_name Bench extends StaticBody3D

func _func_godot_apply_properties(props: Dictionary) -> void:
	if props.has("name"):
		self.name = props["name"]
