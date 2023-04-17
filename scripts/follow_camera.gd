extends Node3D

func _enter_tree():
	visible = true

func _process(_delta):
	global_transform.origin = get_viewport().get_camera_3d().global_transform.origin
