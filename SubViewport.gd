extends SubViewport

func _ready():
	var v := get_parent().get_viewport()
	world_3d = v.world_3d
	size = v.size
	$far_camera.real_camera = v.get_camera_3d()
