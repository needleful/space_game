extends Tool

@export_range(0.0, 10000.0, 1.0, "or_greater") var power := 400.0

var thruster_entity: PackedScene = preload("res://tool_helpers/thruster.tscn")

func _init():
	tool_name = "Thruster"

func can_fire():
	return is_colliding() and get_collider() is RigidBody3D

func _fire(p_position: Vector3, p_normal: Vector3, object):
	var t = thruster_entity.instantiate()
	t.power = power
	object.add_child(t)
	t.global_transform.origin = p_position
	t.orient_to(p_normal)
