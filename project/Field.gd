extends Spatial

# signals

# enums

# constants

# exported variables
export var camera_zoom_speed := 0.1
export var camera_rotate_speed := 0.001 # percentage of full circle

# variables
var _ignore

# onready variables
onready var _camera_arm := $CameraArm
onready var _camera := $CameraArm/Camera


func _ready()->void:
	randomize()
	camera_rotate_speed *= TAU # so it's actually a percent of a full circle


func _process(_delta:float)->void:
	if Input.is_action_pressed("zoom_in"):
		_camera.translation.z -= camera_zoom_speed
	if Input.is_action_pressed("zoom_out"):
		_camera.translation.z += camera_zoom_speed
	if Input.is_action_pressed("rotate_camera_down"):
		_camera_arm.rotation.x += camera_rotate_speed
	if Input.is_action_pressed("rotate_camera_left"):
		_camera_arm.rotation.y -= camera_rotate_speed
	if Input.is_action_pressed("rotate_camera_right"):
		_camera_arm.rotation.y += camera_rotate_speed
	if Input.is_action_pressed("rotate_camera_up"):
		_camera_arm.rotation.x -= camera_rotate_speed

