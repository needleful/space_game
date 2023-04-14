extends HBoxContainer

signal changed(opt_name, value)

var option_name:String

func set_option_hint(option:Dictionary):
	if option.hint == PROPERTY_HINT_RANGE:
		var hint:PackedStringArray = option.hint_string.split(",")
		$slider.min_value = float(hint[0])
		$slider.max_value = float(hint[1])
		if hint.size() == 3:
			$slider.step = float(hint[2])
	option_name = option.name

func set_option_value(val:float):
	$label.text = str(val)
	$slider.value = val

func grab_focus():
	$slider.grab_focus()

func _on_value_changed(value):
	$label.text = str(value)
	emit_signal("changed", option_name, value)
