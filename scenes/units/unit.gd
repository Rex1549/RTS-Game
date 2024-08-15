extends CharacterBody3D

class_name Unit

# Nodes
@onready var nav_agent :NavigationAgent3D = $NavigationAgent3D
@onready var selection_sprite :Sprite3D = $Selected

# Constants
@export var SPEED :float
@export var ACCELERATION :float
@export var ROTATION_SPEED :float
@export var TEAM: int

# Flags
@export var is_tracked :bool

# Variables
var facing :Vector3


# Ready is called once for the node when it joins the scene tree
func _ready():
	deselect()
	set_values()


# Physics process is called at fixed intervals (60Hz)
func _physics_process(delta):
	if not nav_agent.is_navigation_finished():
		calculate_unit_transform()
		move_and_slide()
	else:
		velocity = velocity.move_toward(Vector3.ZERO, 1.5)
		move_and_slide()


# Calculates and applies the transforms of the object for path-following
func calculate_unit_transform() -> void:
	# Fetch the current location from the objects global transform
	var current_location = global_transform.origin
	# Get the goal location of the next position in the path
	var next_location = nav_agent.get_next_path_position()
	# Calculate the direction from the current position to the goal position that the object needs to turn towards
	var commanded_direction = current_location.direction_to(next_location)
	
	# TODO - Add a command so that the facing of a vehicle can be modified
	# Ex : rotation when it arrives at it's target destination
	facing = commanded_direction
	
	# saves the current rotation quaternion then looks at the target and sets the target quaternion
	var target_rotation = Quaternion(Basis.looking_at(next_location - transform.origin)).normalized()
	
	# Rotates the object by spherical interpolation towards the facing the unit is targeting
	self.quaternion = rotate_towards(self.quaternion, target_rotation, ROTATION_SPEED)
	
	# Calculate the dot product to the current target direction
	var direction_closeness = transform.basis.x.dot(commanded_direction)
	
	# If the unit facing is close to the commanded direction, increase speed until it is at max speed
	if abs(direction_closeness) < 0.4:
		velocity = velocity.move_toward(-transform.basis.z * SPEED, 1)
	elif abs(direction_closeness) > 0.4 and not velocity.is_zero_approx():
		velocity = velocity.move_toward(Vector3.ZERO, 0.5)
	else:
		velocity = velocity.move_toward(Vector3.ZERO, 1.5)


# Rotates quaternion A towards quaternion B at a fixed angular velocity
func rotate_towards(a: Quaternion, b: Quaternion, angle: float) -> Quaternion:
	var angle_to: float = a.angle_to(b)
	if angle_to > angle:
		return a.slerp(b, angle/angle_to)
	else:
		return b;


# Updates the pathfinding target location
# TODO - Create a NavigationServer3D implementation of the path request using the navigation maps
func update_target_location(target_location:Vector3):
	nav_agent.target_position = target_location


# TODO - DEBUG : remove when units are defined
func set_values() -> void:
	SPEED = 10
	ROTATION_SPEED = 0.05
	TEAM = 1


# Sets the visibility of the selection sprite of the unit to true
	SPEED = 50.
	ACCELERATION = 0.5
	team = 1

func select() -> void:
	selection_sprite.visible = true


# Sets the visibility of the selection sprite of the unit to false
func deselect() -> void:
	selection_sprite.visible = false
