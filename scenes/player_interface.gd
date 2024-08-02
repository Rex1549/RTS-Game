extends Control

# Nodes
@onready var ui_selection_patch :NinePatchRect = $SelectionRect
@onready var player_camera :Camera3D = $Camera/Yaw/Pitch/MainCamera
@onready var add_unit_button = $Button # DEBUG
@onready var spin_box = $SpinBox # DEBUG
const UNIT = preload("res://scenes/unit.tscn")

# Modules
const camera_operations:GDScript = preload("res://resources/scripts/camera_operations.gd")

# Variables
var selected_units :Dictionary = {}

# Internal Variables
var _mouse_left_click :bool = false
var _dragged_rect :Rect2

# Constants
const MIN_SELECT_SQUARED :float = 81

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialise the interface for the start of the game
	initialise_interface()


func initialise_interface() -> void:
	# Defaults the selection rectangle in the UI to invisible
	ui_selection_patch.visible = false


func _input(event:InputEvent) -> void:
	# Runs once at the start of each selection rect
	if Input.is_action_just_pressed("mouse_left_click"):
		# Updates the dragged rect start position
		_dragged_rect.position = get_global_mouse_position()
		ui_selection_patch.position = _dragged_rect.position
		_mouse_left_click = true
	
	# Runs once at the end of each selection rect
	if Input.is_action_just_released("mouse_left_click"):
		# Hides the UI selection patch
		_mouse_left_click = false
		ui_selection_patch.visible = false
		# Casts the selection and adds any units into the selection
		cast_selection()
	
	if Input.is_action_just_pressed("mouse_right_click"):
		if not selected_units.is_empty():
			var mouse_position :Vector2 = get_viewport().get_mouse_position()
			var camera :Camera3D = get_viewport().get_camera_3d()
			
			var camera_raycast_coords :Vector3 = camera_operations.global_position_from_raycast(camera, mouse_position)
			if not camera_raycast_coords.is_zero_approx():
				for key in selected_units:
					selected_units[key].update_target_location(camera_raycast_coords)
			print(camera_raycast_coords)


func cast_selection() -> void:
	# Clears the selection
	# TODO Add modifier keys that either clear the selection or add to selection, etc...
	selected_units.clear()
	for unit in get_tree().get_nodes_in_group("units"):
		# Checks if each unit is contained within the dragged circle selection and selects them if so
		if _dragged_rect.abs().has_point(player_camera.project_to_screen(unit.transform.origin)):
			selected_units[unit.get_instance_id()] = unit
			unit.select()
		else:
			unit.deselect()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta:float) -> void:
	if _mouse_left_click:
		# Update the size of the dragged rect
		_dragged_rect.size = get_global_mouse_position() - _dragged_rect.position
	
		# Update the UI rect's position and scale
		update_ui_selection_rect()
		cast_selection()
		
		# Only show the ui_rect if it's above a certain size to avoid it always appearing
		if _dragged_rect.size.length_squared() > MIN_SELECT_SQUARED:
			ui_selection_patch.visible = true


func update_ui_selection_rect() -> void:
	# Gives the UI rect the same size as the dragged rect (absoluted since a NinePatchRect can't have a negative size)
	ui_selection_patch.size = abs(_dragged_rect.size)
	
	# Negative scaling since NinePatchRect only allows for positive sizes
	# Scale the nine patch rect X axis by -1 to enable dragging left
	if _dragged_rect.size.x < 0:
		ui_selection_patch.scale.x = -1
	else:
		ui_selection_patch.scale.x = 1
	
	# Scale the nine patch rect Y axis by -1 to enable dragging up
	if _dragged_rect.size.y < 0:
		ui_selection_patch.scale.y = -1
	else:
		ui_selection_patch.scale.y = 1


# DEBUG - TODO Remove
func spawn_unit() -> void:
	for i in spin_box.value:
		var unit:CharacterBody3D = UNIT.instantiate()
		unit.transform.origin = Vector3(-5.932, 3.282, -15.371 + i)
		get_parent().add_child(unit)
