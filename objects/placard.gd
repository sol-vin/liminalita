@tool
extends MeshInstance3D

@export var title := "":
	set(n_title):
		title = n_title
		set_title()

@export_multiline var description := "":
	set(n_description):
		description = n_description
		set_description()

func set_title():
	$Title.text = title

func set_description():
	$Description.text = description
