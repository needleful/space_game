extends Tool

@export_range(0.0, 10000.0, 1.0, "or_greater") var power := 400.0

var thruster_entity: PackedScene = preload("res://tool_helpers/thruster.tscn")

func _init():
	tool_name = "Thruster"
	object_mask = 36

func can_fire():
	return is_colliding()

func _fire(p_position: Vector3, p_normal: Vector3, object):
	if object is ThrusterEnt:
		object.power = power
		return
	var t = thruster_entity.instantiate()
	t.power = power
	object.add_child(t)
	t.global_transform.origin = p_position
	t.orient_to(p_normal)
