extends Camera3D

var real_camera: Camera3D:
	set(value):
		real_camera = value
		if real_camera.has_signal("position_changed"):
			var _x = real_camera.connect("position_changed", _on_camera_position_changed)

func _on_camera_position_changed():
	global_transform = real_camera.global_transform

func _process(_delta):
	fov = real_camera.fov
	near = real_camera.far
