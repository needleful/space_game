extends DirectionalLight3D

@export var player: Node3D

func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		RenderingServer.global_shader_parameter_set("sun_position", global_transform.origin)

func _process(_delta):
	var l = player.global_transform.origin - global_transform.origin
	l = Vector3(l.y, l.z, l.x).normalized()
	if l.is_normalized():
		global_transform = global_transform.looking_at(player.global_transform.origin, l)
