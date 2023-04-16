extends Tool

func _init():
	tool_name = "Remover"

func can_fire():
	return is_colliding()

func fire(_pos, _n, object):
	object.queue_free()
