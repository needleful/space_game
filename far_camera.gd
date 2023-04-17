extends Camera3D

var real_camera: Camera3D

func _process(_delta):
	global_transform = real_camera.global_transform
	fov = real_camera.fov
	near = real_camera.far
