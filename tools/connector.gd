extends Tool

var queued_object: CollisionObject3D
const activated = "activated"

func _init():
	tool_name = "Connector"
	# mask 6
	object_mask = 32

func activate(player):
	super.activate(player)
	queued_object = null

func cancel():
	queued_object = null

func can_fire():
	if !is_colliding():
		return false
	if !queued_object:
		return get_collider().has_signal(activated)
	else:
		return "on_activated" in get_collider()

func fire(_pos, _normal, object: CollisionObject3D):
	if !queued_object:
		queued_object = object
	elif !queued_object.is_connected(activated, get_collider().on_activated):
		var res = queued_object.connect(activated, object.on_activated)
		if res == OK:
			print("Connected %s to %s" % [object.name, queued_object.name] )
		else:
			print_debug("Failed to connect %s to %s: Code %d" % [
				object.name, queued_object.name, res] )
		queued_object = null

