extends CanvasLayer

signal unit_selected(unit_path)
signal button_pressed(other_button_id)
signal start_game

const _GOOD_UNIT_NAMES := [
	"Melee Unit",
	"Ranged Unit",
]
const _BAD_UNIT_NAMES := [
	"Bad Unit",
]
const _UNIT_PATHS := {
	"Melee Unit":"res://Units/Basic/MeleeUnit.tscn",
	"Ranged Unit":"res://Units/Basic/MeleeUnit.tscn",
	"Bad Unit":"res://Units/Basic/MeleeUnit.tscn",
}
const _UNIT_SETS := 2

enum UnitSet {GOOD, BAD}

export var button_height := 24.0

var _unit_set = UnitSet.GOOD

onready var _tabs = $TabContainer as TabContainer

func _ready()->void:
	var buttons_created := 0
	for unit_set in _UNIT_SETS:
		var button_container := HBoxContainer.new()
		button_container.name = UnitSet.keys()[unit_set]
		button_container.margin_top = -button_height
	
		var unit_names := []
		match unit_set:
			UnitSet.GOOD:
				unit_names = _GOOD_UNIT_NAMES
			UnitSet.BAD:
				unit_names = _BAD_UNIT_NAMES

		assert(unit_names.size() > 0)
	
		var UnitButton := load("res://UI/UnitButton.tscn")
		for unit_name in unit_names:
			var unit_button = UnitButton.instance() as Button
			button_container.add_child(unit_button)
			unit_button.unit_name = unit_name
			unit_button.button_id = buttons_created
			buttons_created += 1
			# warning-ignore:return_value_discarded
			unit_button.connect("custom_pressed", self, "_on_UnitButton_pressed")
			connect("button_pressed", unit_button, "_on_other_button_pressed")
		_tabs.add_child(button_container)


func _on_UnitButton_pressed(unit_name:String, button_id:int)->void:
	var unit_path = _UNIT_PATHS[unit_name] as String
	emit_signal("unit_selected", unit_path)
	emit_signal("button_pressed", button_id)



func _on_StartButton_pressed()->void:
	emit_signal("start_game")
