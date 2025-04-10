extends Node3D

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("interact"):
		#$"Lobby Square/entity_47_player".teleport_in_relation_to($"Lobby Square/square_infinite_room", $"Lobby Square/square_infinite_room_trap")
