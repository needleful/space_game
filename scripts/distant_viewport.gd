extends SubViewport

func _ready():
	print("Readying viewport")
	var v := get_parent().get_viewport()
	world_3d = v.world_3d
	size = v.size
	$far_camera.real_camera = v.get_camera_3d()
	get_texture()
	v.connect("size_changed", update_size)

func update_size():
	var v := get_parent().get_viewport()
	size = v.size
