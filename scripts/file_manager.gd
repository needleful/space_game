extends Node

var required_folders := [
	"user://scripts",
	"user://custom_entities"
]

func _enter_tree():
	for f in required_folders:
		if !DirAccess.dir_exists_absolute(f):
			DirAccess.make_dir_absolute(f)
