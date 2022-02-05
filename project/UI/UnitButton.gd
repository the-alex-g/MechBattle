extends Button

signal custom_pressed(unit_name, button_id)

var unit_name := "" setget _set_unit_name
var button_id := 0


func _set_unit_name(new_unit_name:String)->void:
	unit_name = new_unit_name
	text = unit_name


func _on_UnitButton_pressed()->void:
	emit_signal("custom_pressed", unit_name, button_id)


func _on_other_button_pressed(other_button_id:int)->void:
	if button_id != other_button_id:
		pressed = false
