extends OptionButton

signal changed(opt_name, value)

var option_name:String

func _ready():
	for c in get_children():
		c.focus_neighbour_left = c.get_path()

func set_option_hint(option:Dictionary):
	option_name = option.name
	var hint: String = option.hint_string
	if hint:
		var values = hint.split(",", false)
		for val in values:
			add_item(val)

func set_option_value(val:String):
	for i in item_count:
		if val == get_item_text(i):
			select(i)
			break

func _on_item_selected(index):
	emit_signal("changed", option_name, get_item_text(index))
