extends Spatial

# signals
signal start_game

# enums
enum GameState {COMBAT, PLACEMENT}

# constants
const CURSOR_SPEED := 2.0
const CAMERA_ROTATE_SPEED := 0.5
const CAMERA_ZOOM_SPEED := 2.0

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
onready var _cursor = $Cursor as MeshInstance
onready var _board_size := half_board_size*2


func _ready()->void:
	randomize()
	
	_gridmap.cell_size = Vector3(tile_size, 0.1, tile_size)
	
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
		
		if Input.is_action_just_pressed("place_unit") and _selected_unit_path != "":
			_create_unit()


func _create_unit()->void:
	var unit:Unit = load(_selected_unit_path).instance()
	add_child(unit)
	unit.translation = Vector3(_cursor.translation.x, 0, _cursor.translation.z)
	# warning-ignore:return_value_discarded
	connect("start_game", unit, "_on_game_start", [], CONNECT_ONESHOT)


func _on_CanvasLayer_unit_selected(unit_path:String)->void:
	_selected_unit_path = unit_path


func _on_CanvasLayer_start_game()->void:
	# this signal is connected to all the units
	_cursor.translation = Vector3(0,-10,0)
	emit_signal("start_game")
	_game_state = GameState.COMBAT
