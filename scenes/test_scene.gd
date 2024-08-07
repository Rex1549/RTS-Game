extends Node3D


@onready var unit = $Unit
@onready var marker_3d = $Marker3D
# deployment variables
@onready var ground_deployment_markers: Node = $map_test/Deployement/Ground
var ground_deployment_positions: Array[Vector3]
var spawn_buffer: Array = []

func _ready():
	await(get_tree().process_frame)
	get_deployment_positions()

func get_deployment_positions() -> void:
	ground_deployment_positions = []
	for child in ground_deployment_markers.get_children():
		print(child.transform.origin)
		ground_deployment_positions.append(child.transform.origin)

func deploy_unit(unit_to_spawn:UnitSpawn) -> void:
	for position in ground_deployment_positions:
		var unit:CharacterBody3D = unit_to_spawn.unit.instantiate()
		unit.transform.origin = position
		get_parent().add_child(unit)
		if "update_target_location" in unit:
			unit.update_target_location(unit_to_spawn.target_coords)

func _on_player_interface_spawn_unit(unit: UnitSpawn):
	print("Calling deploy unit.")
	deploy_unit(unit)
