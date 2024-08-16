extends Node3D

class_name DeploymentMarker

var spawn_buffer: Array[UnitSpawn] = []
var spawn_buffer_len: int = 0

var deployment_counter: int = 0


func _physics_process(_delta):
	if spawn_buffer_len > 0:
		deployment_counter += 1
		if deployment_counter >= 60:
			var unit: UnitSpawn = spawn_buffer.pop_front()
			deploy_unit(unit)
			deployment_counter = 0


func queue_unit(unit_to_spawn:UnitSpawn) -> void:
	# adds a unit to the spawn queue
	spawn_buffer.append(unit_to_spawn)
	spawn_buffer_len += 1


func deploy_unit(unit_to_spawn:UnitSpawn) -> void:
	# spawns a unit with a path to the desired position
	var unit:Node3D = unit_to_spawn.unit.instantiate()
	unit.TEAM = unit_to_spawn.unit_team
	unit.transform.origin = get_position()
	get_parent().add_child(unit)
	if "update_target_location" in unit:
		unit.update_target_location(unit_to_spawn.target_coords)
	spawn_buffer_len -= 1

