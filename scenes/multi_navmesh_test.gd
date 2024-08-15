extends Node3D

@onready var marker :DeploymentMarker = $DeploymentMarker

func _on_player_interface_spawn_unit(unit: UnitSpawn):
	print("Adding unit to deployment buffer.")
	# find closest deployment marker
	marker.queue_unit(unit)
