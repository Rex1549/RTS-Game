extends Node3D


@onready var unit = $Unit
@onready var marker_3d = $Marker3D


func _ready():
	await(get_tree().process_frame)
