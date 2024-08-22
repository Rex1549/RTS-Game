extends Camera3D


@onready var camera = $"../../.."
@onready var yaw = $"../.."
@onready var pitch = $".."

# Camera Parameters
@export var PAN_SPEED :float
@export var ROT_SPEED :float
@export var ZOOM_SPEED :float

# Constants
const MAX_HEIGHT :float = 10000
const MIN_HEIGHT :float = 300

# Internal Variables
var goal_transform :Vector3 = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	camera.global_position = Vector3(0, 30, 0)
	pitch.global_rotation = Vector3(-PI/4, 0, 0)
	
	goal_transform = camera.global_transform.origin


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Pan the camera in 2D over the map
	var dir :Vector2 = Input.get_vector("left", "right", "up", "down") * PAN_SPEED * delta * camera.global_transform.origin.y
	var dir_3D :Vector3 = Vector3(dir.x, 0, dir.y)
	
	goal_transform += dir_3D.rotated(Vector3.UP, yaw.global_rotation.y)
	
	
	# Zoom the camera in and out
	if Input.is_action_just_pressed("zoom_out"):
		if not goal_transform.y >= MAX_HEIGHT:
			goal_transform += Vector3(0, ZOOM_SPEED, 0).rotated(Vector3.LEFT, pitch.global_rotation.x)
	
	if Input.is_action_just_pressed("zoom_in"):
		if not goal_transform.y <= MIN_HEIGHT:
			goal_transform -= Vector3(0, ZOOM_SPEED, 0).rotated(Vector3.LEFT, pitch.global_rotation.x)
	
	camera.global_transform.origin = camera.global_transform.origin.lerp(goal_transform, 0.1)


# Projects the 3D world space coordinate into the camera's 2D screen space
func project_to_screen(point:Vector3) -> Vector2:
	return unproject_position(point)







