extends Tool

var queued_object: CollisionObject3D

func _init():
	tool_name = "Weld"

func activate(player):
	super.activate(player)
	queued_object = null

func fire(_pos, _normal, object: CollisionObject3D):
	if !queued_object:
		queued_object = object
		return
	elif queued_object == object:
		queued_object = null
		if object is RigidBody3D:
			object.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_AUTO
		return

	var large_object: CollisionObject3D
	var small_object: RigidBody3D
	if object is RigidBody3D:
		small_object = object
		large_object = queued_object
	elif queued_object is RigidBody3D:
		small_object = queued_object
		large_object = object
	else:
		# Cannot weld non-rigid bodies to each other
		queued_object = null
		return
	
	# TODO: figure out a way to preserve interactions and physical properties
	# of the child objects.
	# This breaks everything, even chairs
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
