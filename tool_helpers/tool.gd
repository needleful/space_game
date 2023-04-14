extends RayCast3D
class_name Tool

var tool_name := ""

func activate(player):
	player.ui.tool_prompt = tool_name

func fire(_position: Vector3, _normal: Vector3, _object: CollisionObject3D):
	pass

func can_fire() -> bool:
	return is_colliding()
