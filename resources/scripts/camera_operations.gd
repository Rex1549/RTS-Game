extends RefCounted
# Holds camera operations


static func global_position_from_raycast(camera:Camera3D, coords2D:Vector2) -> Vector3:
	var ray_from :Vector3 = camera.project_ray_origin(coords2D)
	var ray_to :Vector3 = ray_from + camera.project_ray_normal(coords2D) * 1000.0
	
	var ray_parameters :PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_from, ray_to, 2)
	
	var result :Dictionary = camera.get_world_3d().get_direct_space_state().intersect_ray(ray_parameters)
	
	if result: return result.position
	else: return Vector3.ZERO

