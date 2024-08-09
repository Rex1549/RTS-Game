extends Node3D


@onready var unit = $Unit
@onready var marker_3d = $Marker3D
# deployment variables
@onready var ground_deployment_marker_container: Node = $map_test/Deployement/Ground
var ground_deployment_markers: Array[DeploymentMarker]


func _ready():
	await(get_tree().process_frame)
	get_deployment_positions()


func _physics_process(delta):
	pass


func get_deployment_positions() -> void:
	ground_deployment_markers = []
	for child in ground_deployment_marker_container.get_children():
		print(child)
		if "get_position" in child:
			ground_deployment_markers.append(child)
		else:
			print("ERROR - spawn marker has no 'get_position' function!")


func _on_player_interface_spawn_unit(unit: UnitSpawn):
	print("Adding unit to deployment buffer.")
	# find closest deployment marker
	var closest: DeploymentMarker
	var distance: float = -1.
	for marker in ground_deployment_markers:
		var dist = marker.get_position().distance_to(unit.target_coords)
		if dist < distance or distance == -1.:
			distance = dist
			closest = marker
	closest.queue_unit(unit)
