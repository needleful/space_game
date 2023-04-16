extends Tool

var queued_object: RigidBody3D

func _init():
	tool_name = "Weld"

func activate(player):
	super.activate(player)
	queued_object = null

func can_fire():
	if !is_colliding():
		return false
	elif !queued_object:
		return get_collider() is RigidBody3D
	return true

func cancel():
	queued_object = null

func fire(_pos, _normal, object: CollisionObject3D):
	if !queued_object:
		queued_object = object as RigidBody3D
		return
	elif queued_object == object:
		queued_object = null
		if object is RigidBody3D:
			object.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_AUTO
		return

	var large_object: CollisionObject3D = object
	var small_object: RigidBody3D = queued_object
	
	#TODO: add a way to track welded objects so they can be split back apart
	for c in small_object.get_children():
		if c is Node3D:
			var t = c.global_transform
			small_object.remove_child(c)
			large_object.add_child(c)
			c.global_transform = t
		else:
			small_object.remove_child(c)
			large_object.add_child(c)
	if large_object is RigidBody3D:
		large_object.mass += small_object.mass
		large_object.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_AUTO
	small_object.queue_free()
	queued_object = null
