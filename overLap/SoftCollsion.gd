extends Area2D

func is_collding():
	var areas = get_overlapping_bodies()
	return areas.size() > 0 
	
func get_push_vector():
	var areas =get_overlapping_bodies()
	print(areas.size())
	var push_vector = Vector2.ZERO
	if is_collding():
		var area = areas[0]
		push_vector = areas.global_position.direction_to(global_position)
		push_vector = push_vector.normalized()
	return push_vector
