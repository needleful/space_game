extends Node3D

@export var prompt: String = "Enter Vehicle"

var user: RigidBody3D
var user_collision_layer : int

func _can_use(player):
	return !user or user == player

func _use(_position, player:RigidBody3D):
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
	var p = get_parent() as RigidBody3D
	if p:
		p.mass += user.mass

func exit():
	remove_child(user)
	get_tree().current_scene.add_child(user)
	user.freeze = false
	user.collision_layer = user_collision_layer
	user.vehicle = null
	user.global_transform = global_transform.translated(
		global_transform.basis.z + global_transform.basis.y)
	var p := get_parent()
	if p is RigidBody3D:
		p.mass -= user.mass
		user.linear_velocity = p.linear_velocity
	elif p is CharacterBody3D:
		user.linear_velocity = p.velocity
	user = null
