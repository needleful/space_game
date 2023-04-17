extends SubViewport

var v: Viewport

func _ready():
	v = get_parent().get_viewport()
	world_3d = v.world_3d
	size = v.size
	$far_camera.real_camera = v.get_camera_3d()
	get_texture()
	v.connect("size_changed", _on_size_changed)

