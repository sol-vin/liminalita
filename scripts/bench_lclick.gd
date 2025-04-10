class_name BenchLeftClickAction extends LeftClickAction

@export var sitting_positions : Node3D

func on_lclick(player : Player):
	player.sit(find_closest_sitting_point(player.global_position))
	
func find_closest_sitting_point(position : Vector3) -> Vector3:
	var closest = null
	var closest_distance = 0.0
	for sitting_position in sitting_positions.get_children():
		if !closest:
			closest = sitting_position
			closest_distance = sitting_position.global_position.distance_to(position)
		else:
			var distance = sitting_position.global_position.distance_to(position)
			if closest_distance > distance:
				closest = sitting_position
				closest_distance = distance
	return closest.global_position
