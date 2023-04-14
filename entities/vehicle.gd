extends Node3D

@export var prompt: String = "Enter Vehicle"

var user: RigidBody3D
var user_collision_layer : int

func can_use(player):
	return !user or user == player

func use(_position, player:RigidBody3D):
	if user == player:
		exit()
		return
	if player.vehicle:
		player.vehicle.exit()
	print("Get in!")
	player.freeze = true
	player.get_parent().remove_child(player)
	add_child(player)
	player.transform = Transform3D()
	player.vehicle = self
	user = player
	user_collision_layer = user.collision_layer
	user.collision_layer = 0

func exit():
	remove_child(user)
	get_tree().current_scene.add_child(user)
	user.freeze = false
	user.collision_layer = user_collision_layer
	user.vehicle = null
	user.global_transform = global_transform.translated(
		global_transform.basis.z + global_transform.basis.y)
	user.linear_velocity = get_parent().linear_velocity
	user = null
