extends Camera3D

var real_viewport: Viewport

func _process(_delta):
	var real_camera := real_viewport.get_camera_3d()
	global_transform = real_camera.global_transform
	fov = real_camera.fov
	near = real_camera.far
