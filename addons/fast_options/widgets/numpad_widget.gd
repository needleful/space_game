extends Control 

signal changed(opt_name, value)

var option_name:String

func set_option_hint(option:Dictionary):
	option_name = option.name

func set_option_value(val:float):
	pass

func grab_focus():
	pass

func _on_value_changed(value):
	pass
	emit_signal("changed", option_name, value)
