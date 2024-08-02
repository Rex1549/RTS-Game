extends CharacterBody3D

# Nodes
@onready var nav_agent :NavigationAgent3D = $NavigationAgent3D
@onready var selection_sprite :Sprite3D = $Selected

# Constants
@export var SPEED :float


func _ready():
	deselect()


func _physics_process(delta):
	if not nav_agent.is_navigation_finished():
		var current_location = global_transform.origin
		var next_location = nav_agent.get_next_path_position()
		var new_velocity = (next_location - current_location).normalized() * SPEED * delta * 10
		
		velocity = velocity.move_toward(new_velocity, .5)
	
		move_and_slide()


func update_target_location(target_location:Vector3):
	nav_agent.target_position = target_location


func select() -> void:
	selection_sprite.visible = true

func deselect() -> void:
	selection_sprite.visible = false
