extends Button

signal custom_pressed(unit_name)

var unit_name := "" setget _set_unit_name


func _set_unit_name(new_unit_name:String)->void:
	unit_name = new_unit_name
	text = unit_name


func _on_UnitButton_pressed()->void:
	emit_signal("custom_pressed", unit_name)
