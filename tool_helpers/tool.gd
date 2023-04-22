extends RayCast3D
class_name Tool

var tool_name := ""
var object_mask := 1
var preview_active := false
var scroll_enabled := false

var player: PlayerBody3D

func activate(p_player):
	player = p_player
	player.ui.tool_prompt = tool_name
	player.tool_cast.collision_mask = object_mask

func can_fire() -> bool:
	return false

func can_fire2() -> bool:
	return false

func fire():
	return _fire(get_collision_point(), get_collision_normal(), get_collider())

func fire2():
	return _fire(get_collision_point(), get_collision_normal(), get_collider())

func preview():
	return _preview(get_collision_point(), get_collision_normal(), get_collider())

func preview_exit():
	pass

func cancel():
	pass

func _fire(_position:Vector3, _normal:Vector3, _object:CollisionObject3D):
	pass

func _fire2(_position:Vector3, _normal:Vector3, _object:CollisionObject3D):
	pass

# Usage: only called when can_fire() and preview_active are true
func _preview(_position:Vector3, _normal:Vector3, _object:CollisionObject3D):
	pass
