extends Node3D
class_name Unit2

# Nodes
@onready var selection_sprite :Sprite3D = $Selected
@onready var map_RID :RID = get_world_3d().get_navigation_map()

# Constants
@export var SPEED :float
@export var ROTATION_SPEED :float
@export var ACCELERATION :float
@export var TEAM :int

# Enums
enum PATHING_MODE {MOVE, MOVE_FAST, ATTACK, COVER}

# Variables
var facing :Vector3
var facing_at_taget_position :Vector3
var velocity :Vector3

# Pathfinding variables
var is_pathing :bool = false
var pathing_mode :PATHING_MODE = PATHING_MODE.MOVE
var unit_navigation_layers :int = 1
var path_next_point_index :int = 0
var path_points :PackedVector3Array

# Navigation parameters
@export var path_desired_distance :float = 1 :
	set(value):
		path_desired_distance = value ** 2
	get:
		return sqrt(path_desired_distance)
@export var target_desired_distance :float = 1 :
	set(value):
		target_desired_distance = value ** 2
	get:
		return sqrt(target_desired_distance)


func _ready() -> void:
	deselect()
	set_values()
	initialise_pathing_parameters()


# Updates the unit's position every frame
func _physics_process(delta:float) -> void:
	if is_pathing:
		_update_unit_position(delta)


# Updates the position of the unit based on its current path
func _update_unit_position(delta:float) -> void:
	# Check if the point is the last point in the path
	var final_point = false
	if path_next_point_index == path_points.size() - 1: final_point = true
	else: final_point = false
	
	# Calculates the distance to the next point of the path and compares it to the target distance
	var path_next_point :Vector3 = path_points[path_next_point_index] - global_position
	if (path_next_point.length_squared() > path_desired_distance and not final_point) or (path_next_point.length_squared() > target_desired_distance and final_point):
		velocity = _unit_move_to(path_next_point)
		global_position += velocity * delta
	else: # Path point reached
		if path_next_point_index < path_points.size() - 1:
			path_next_point_index += 1 # fetch the next path point
			velocity = _unit_move_to(path_next_point)
			global_position += velocity * delta
		else: # Target position reached
			if facing_at_taget_position.is_zero_approx():
				is_pathing = false
			else:
				# Facing of a vehicle is modified if it has arrived at the end of it's position
				var alignment = _unit_rotate_to(facing_at_taget_position)
				if alignment < 0.1:
					is_pathing = false


# Moves the unit based on its relevant movement code. Should be overriden by inheriting objects
# The function takes as an argument the target position RELATIVE TO THE UNIT for the movement and returns the velocity vector for the movement
func _unit_move_to(target_position:Vector3) -> Vector3:
	# Update the facing of the unit given the target position
	var target_facing = target_position.normalized()
	var direction_closeness = _unit_rotate_to(target_facing)
	
	# If the unit facing is close to the commanded direction, increase speed until it is at max speed
	if abs(direction_closeness) < 0.3:
		return velocity.move_toward(-transform.basis.z * SPEED, 1)
	elif abs(direction_closeness) >= 0.3 and not velocity.is_zero_approx():
		return velocity.move_toward(Vector3.ZERO, 0.5)
	else:
		return velocity.move_toward(Vector3.ZERO, 1.5)


# Returns the dot product between the target facing and the right vector (0 means the turn is completed)
func _unit_rotate_to(target_facing:Vector3) -> float:
	# saves the current rotation quaternion then looks at the target and sets the target quaternion
	var target_rotation = Quaternion(Basis.looking_at(target_facing)).normalized()
	# Rotates the object by spherical interpolation towards the facing the unit is targeting
	self.quaternion = rotate_towards(self.quaternion, target_rotation, ROTATION_SPEED)
	# Calculate the dot product to the current target direction and returns it
	return transform.basis.x.dot(target_facing)


# Rotates quaternion A towards quaternion B at a fixed angular velocity
func rotate_towards(a: Quaternion, b: Quaternion, angle: float) -> Quaternion:
	var angle_to: float = a.angle_to(b)
	if angle_to > angle:
		return a.slerp(b, angle/angle_to)
	else:
		return b;


func update_target_location(goal_position:Vector3, mode:PATHING_MODE = PATHING_MODE.MOVE, facing_at_target:Vector3 = Vector3.ZERO) -> void:
	# Find the nearest point that is contained within the navigation map's navigable surfaces
	var safe_goal_position :Vector3 = NavigationServer3D.map_get_closest_point(map_RID, goal_position)
	# Query the navigation server to obtain an array of points representing the shortest path from the from position to the to position
	path_points = NavigationServer3D.map_get_path(map_RID, global_position, safe_goal_position, true, unit_navigation_layers)
	# Set the unit to be pathing with the passed pathing mode and reset the path evaluation index to zero
	is_pathing = true
	pathing_mode = mode
	path_next_point_index = 0
	# Set the facing at the target point
	facing_at_taget_position = facing_at_target
	
	if path_points.size() == 0:
		is_pathing = false
	


# Assigns the default values to the constants
func set_values() -> void:
	SPEED = 10
	ROTATION_SPEED = 0.05
	ACCELERATION = 0.5
	TEAM = 1

func initialise_pathing_parameters() -> void:
	print(NavigationServer3D.get_maps())
	map_RID = NavigationServer3D.get_maps()[0]

# Deselects the unit by hiding the selection visuals
func deselect() -> void:
	selection_sprite.set_visible(false)

# Selects the unit by making visible the selection sprite
func select() -> void:
	selection_sprite.set_visible(true)
