extends CharacterBody3D

class_name Unit

# Nodes
@onready var nav_agent :NavigationAgent3D = $NavigationAgent3D
@onready var selection_sprite :Sprite3D = $Selected

# Constants
@export var SPEED :float
const SPEED_MULT :float = 5

# Team
@export var team: int

func _ready():
	deselect()
	set_values()


func _physics_process(delta):
	if not nav_agent.is_navigation_finished():
		velocity = get_unit_velocity(delta)
		move_and_slide()

func get_unit_velocity(delta) -> Vector3:
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED * delta * SPEED_MULT
	return velocity.move_toward(new_velocity, .5)

func update_target_location(target_location:Vector3):
	nav_agent.target_position = target_location

func set_values() -> void:
	SPEED = 50.
	team = 1

func select() -> void:
	selection_sprite.visible = true

func deselect() -> void:
	selection_sprite.visible = false