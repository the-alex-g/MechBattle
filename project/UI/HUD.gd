extends CanvasLayer

signal unit_selected(unit_path)

const _GOOD_UNIT_NAMES := [
	"Melee Unit",
	"Ranged Unit",
]
const _BAD_UNIT_NAMES := [
	
]
const _GOOD_UNIT_PATHS := {
	"Melee Unit":"res://Units/Basic/MeleeUnit.tscn",
	"Ranged Unit":"res://Units/Basic/MeleeUnit.tscn",
}

enum UnitSet {GOOD, BAD}

export var button_height := 24.0

var _unit_set = UnitSet.GOOD

onready var _button_container = $HBoxContainer as HBoxContainer

func _ready()->void:
	_button_container.margin_top = -button_height
	
	var _unit_names := []
	match _unit_set:
		UnitSet.GOOD:
			_unit_names = _GOOD_UNIT_NAMES
		UnitSet.BAD:
			_unit_names = _BAD_UNIT_NAMES
	
	assert(_unit_names.size() > 0)
	
	var UnitButton := load("res://UI/UnitButton.tscn")
	for unit_name in _unit_names:
		var unit_button = UnitButton.instance() as Button
		_button_container.add_child(unit_button)
		unit_button.unit_name = unit_name
		# warning-ignore:return_value_discarded
		unit_button.connect("custom_pressed", self, "_on_UnitButton_pressed")


func _on_UnitButton_pressed(unit_name:String)->void:
	var unit_path = _GOOD_UNIT_PATHS[unit_name] as String
	emit_signal("unit_selected", unit_path)

