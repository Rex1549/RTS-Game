extends Node3D

# Nodes
@onready var marker :DeploymentMarker = $DeploymentMarker

# Navigation structures
var navigation_maps_RID :Dictionary = {}

func _on_player_interface_spawn_unit(unit: UnitSpawn):
	print("Adding unit to deployment buffer.")
	# find closest deployment marker
	marker.queue_unit(unit)


func _ready() -> void:
	call_deferred("_initialise_navigation_server")


func _initialise_navigation_server() -> void:
	# Initialise the ground navigation map
	navigation_maps_RID["ground"] = NavigationServer3D.get_maps()[0]
	
	# Initialise the air navigation map
	navigation_maps_RID["air"] = NavigationServer3D.map_create()
	
	# load the navigation regions and add them to the maps
	var forest_region :NavigationRegion3D = $multi_nav_test/forest
	var road_region :NavigationRegion3D = $multi_nav_test/road
	var grass_region :NavigationRegion3D = $multi_nav_test/grass
	#var air_region :NavigationRegion3D = $multi_nav_test/air
	
	# Modify regions
	# TODO - modify region parameters for navigation
	
	# Assign the regions to their respective maps
	NavigationServer3D.region_set_map(forest_region, navigation_maps_RID["ground"])
	NavigationServer3D.region_set_map(road_region, navigation_maps_RID["ground"])
	NavigationServer3D.region_set_map(grass_region, navigation_maps_RID["ground"])
	
	# Activates the maps
	NavigationServer3D.map_set_active(navigation_maps_RID["ground"], true)
	NavigationServer3D.map_set_active(navigation_maps_RID["air"], true)
	












