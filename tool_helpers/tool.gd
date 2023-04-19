extends RayCast3D
class_name Tool

var tool_name := ""
var object_mask := 1

func activate(player):
	player.ui.tool_prompt = tool_name
	player.tool_cast.collision_mask = object_mask

func can_fire() -> bool:
	return false

func can_fire2() -> bool:
	return false

func fire(_position: Vector3, _normal: Vector3, _object: CollisionObject3D):
	pass

func fire2(_position:Vector3, _normal:Vector3, _object:CollisionObject3D):
	pass

func cancel():
	pass
