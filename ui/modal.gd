extends Control


@export var mode := 0:
	get:
		return mode
	set(value):
		if !is_inside_tree():
			mode = value
		elif value < 0 or value >= get_child_count():
			print_debug("Error: bad mode ", value)
		else:
			mode = value
			for c in get_children():
				c.hide()
			get_child(mode).show()

func _ready():
	mode = mode
