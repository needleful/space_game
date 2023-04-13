extends Tool

var thruster_entity: PackedScene = preload("res://tool_helpers/thruster.tscn")

func _init():
	tool_name = "Thruster"
	
func fire(p_position: Vector3, p_normal: Vector3, object: CollisionObject3D):
	var t = thruster_entity.instantiate()
	object.add_child(t)
	t.global_transform.origin = p_position
	t.orient_to(p_normal)
