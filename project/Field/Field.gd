extends Spatial

# signals

# enums

# constants

# exported variables
export var camera_zoom_speed := 0.1
export var camera_rotate_speed := 0.001 # percentage of full circle
export var board_size := 2
export var tile_size := 16

# variables
var _ignore

# onready variables
onready var _camera_arm := $CameraArm
onready var _camera := $CameraArm/Camera
onready var _gridmap := $GridMap


func _ready()->void:
	randomize()
	camera_rotate_speed *= TAU # so it's actually a percent of a full circle
	
	_gridmap.cell_size = Vector3(tile_size, 0.1, tile_size)
	
	# create board
	
	for row in board_size:
		row -= board_size/2
		
		for column in board_size:
			column -= board_size/2
			
			_gridmap.set_cell_item(column, 0, row, 0)


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

