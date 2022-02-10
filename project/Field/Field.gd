extends Spatial

# signals
signal start_game

# enums
enum GameState {COMBAT, PLACEMENT}

# constants
const CURSOR_SPEED := 10.0
const CAMERA_ROTATE_SPEED := 0.5
const CAMERA_ZOOM_SPEED := 2.0
const DEFAULT_NEAR_CLIP := 0.05
const DEFAULT_FAR_CLIP := 100.0
const PERSPECTIVE_ANGLE := 80.0
const ORTHO_SIZE := 50.0

# exported variables
export var half_board_size := 1
export var tile_size := 16

# variables
var _ignore
var _game_state = GameState.PLACEMENT
var _selected_unit_path := ""

# onready variables
onready var _camera_arm = $CameraArm as Position3D
onready var _camera = $CameraArm/Camera as Camera
onready var _gridmap = $GridMap as GridMap
onready var _cursor = $Cursor as Area
onready var _board_size := half_board_size*2


func _ready()->void:
	randomize()
	
	_gridmap.cell_size = Vector3(tile_size, 0.1, tile_size)
	
	# setup camera
	_camera_arm.rotation.x = -TAU/4
	_camera.set_orthogonal(ORTHO_SIZE, DEFAULT_NEAR_CLIP, DEFAULT_FAR_CLIP)
	
	# create board
	for row in _board_size:
		row -= half_board_size
		
		for column in _board_size:
			column -= half_board_size
			
			_gridmap.set_cell_item(column, 0, row, 0)


func _process(delta:float)->void:
	if _game_state == GameState.COMBAT:
		# move camera
		_camera.translation.z += Input.get_axis("zoom_in", "zoom_out") * delta * CAMERA_ZOOM_SPEED
		
		var camera_rotation := Vector3(
			Input.get_axis("rotate_camera_up", "rotate_camera_down"),
			Input.get_axis("rotate_camera_left", "rotate_camera_right"),
			0
		)
		camera_rotation = camera_rotation.normalized() * delta * CAMERA_ROTATE_SPEED
		_camera_arm.rotation += camera_rotation
	
	elif _game_state == GameState.PLACEMENT:
		# move cursor
		var cursor_movement := Vector3 (
			Input.get_axis("move_cursor_left", "move_cursor_right"),
			0,
			Input.get_axis("move_cursor_up", "move_cursor_down")
		)
		cursor_movement = cursor_movement.normalized() * delta * CURSOR_SPEED
		_cursor.translation += cursor_movement
		
		#zoom camera
		_camera.size += Input.get_axis("zoom_in", "zoom_out") * CAMERA_ZOOM_SPEED
		
		if Input.is_action_just_pressed("place_unit") and _selected_unit_path != "":
			_create_unit()
		
		if Input.is_action_just_pressed("remove_unit"):
			var overlapping_bodies = _cursor.get_overlapping_bodies() as Array
			for body in overlapping_bodies:
				body = body as PhysicsBody
				if body.is_in_group("UNIT"):
					disconnect("start_game", body, "_on_game_start")
					body.queue_free()


func _create_unit()->void:
	var unit:Unit = load(_selected_unit_path).instance()
	add_child(unit)
	unit.id = "placed"
	unit.translation = Vector3(_cursor.translation.x, 0, _cursor.translation.z)
	# warning-ignore:return_value_discarded
	connect("start_game", unit, "_on_game_start", [], CONNECT_ONESHOT)


func _on_CanvasLayer_unit_selected(unit_path:String)->void:
	_selected_unit_path = unit_path


func _on_CanvasLayer_start_game()->void:
	# setup camera
	_camera_arm.rotation.x = -TAU/8
	_camera.set_perspective(PERSPECTIVE_ANGLE, DEFAULT_NEAR_CLIP, DEFAULT_FAR_CLIP)
	
	# this signal is connected to all the units
	_cursor.translation = Vector3(0,-10,0)
	emit_signal("start_game")
	_game_state = GameState.COMBAT
