extends ColorPickerButton

signal changed(opt_name, value)

var option_name:String

func set_option_hint(option:Dictionary):
	option_name = option.name
	if option_name.

func set_option_value(val:Color):
	color = val

func _on_color_changed(c):
	emit_signal("changed", option_name, c)
