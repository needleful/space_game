extends Tool

func _init():
	tool_name = "Remover"

func can_fire():
	return is_colliding() and !(get_collider() is StaticBody3D)

func _fire(_pos, _n, object):
	object.queue_free()
