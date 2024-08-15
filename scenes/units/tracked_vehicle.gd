extends Unit

class_name TrackedVehicle

@export var ROTATION_SPEED: float = 0.5 # speed in radians/sec

func set_values() -> void:
	SPEED = 50.0
	ROTATION_SPEED = 1.
	ACCELERATION = 0.2

# this function decides how the unit moves towards it's next navigation point
func get_unit_velocity(delta) -> void:
	# STEP 1 - rotate to correct direction
	var current_direction = global_basis.x # get current facing direction
	var next_location = nav_agent.get_next_path_position()
	var next_direction = global_position.direction_to(next_location).normalized()
	# calculate angle to turn
	var v1 = Vector2(current_direction.x, current_direction.z)
	var v2 = Vector2(next_direction.x, next_direction.z)
	var to_angle = atan2(v2.y,v2.x) - atan2(v1.y,v1.x)
	# correct weird angle behaviour
	if to_angle > PI:
		to_angle = -to_angle + PI
	elif to_angle < -PI:
		to_angle = -to_angle - PI
	if to_angle > 0.1:
		global_rotate(Vector3.UP, -ROTATION_SPEED * delta)
	elif to_angle < -0.1:
		global_rotate(Vector3.UP, ROTATION_SPEED * delta)
	
	# STEP 2 - move forward
	# check if facing is correct
	if to_angle > -0.5 or to_angle < 0.5:
		# allow movement
		var new_velocity = current_direction * SPEED * delta * SPEED_MULT
		new_velocity.y = next_direction.y
		velocity = velocity.move_toward(new_velocity, ACCELERATION)
	move_and_slide()
	#var current_location = global_transform.origin
	#var current_direction = global_transform.basis
	#var next_location = nav_agent.get_next_path_position()
	## get necessary rotation
	#var necessary_rotation:float = current_direction.x.angle_to(next_location)
	## rotate towards target
	#var partial_rotation = move_toward(0, necessary_rotation, ROTATION_SPEED)
	#rotate(Vector3.UP, partial_rotation)
	#print(partial_rotation)
	#if necessary_rotation < 1 or necessary_rotation > -1:
		## move towards target
		#var new_velocity = (next_location - current_location).normalized() * SPEED * delta * SPEED_MULT
		#velocity = velocity.move_toward(new_velocity, .1)
