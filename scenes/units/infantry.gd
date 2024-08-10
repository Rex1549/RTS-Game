extends Unit

class_name Infantry

func set_values() -> void:
	SPEED = 10.0

# this function decides how the unit moves towards it's next navigation point
func get_unit_velocity(delta) -> Vector3:
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED * delta * SPEED_MULT
	
	return velocity.move_toward(new_velocity, .1)
