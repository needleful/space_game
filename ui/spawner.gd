extends Panel

signal spawn(item: PackedScene)

enum Mode {
	SCENES,
	SCRIPTS
}

@export var directory := "entities"
@export var expand_folder_depth := 0
@export var mode := Mode.SCENES
@onready var spawn_list:Tree = $margin/scroll/spawn_list
var default_icon = load("res://addons/fast_options/assets/node_icon.png")

# TODO: make this check for new props dynamically probably
var stuff_loaded := false

var spawnable : Array

func _ready():
	var _x = connect("visibility_changed", _on_visibility_changed)
	_x = spawn_list.connect("item_activated", _on_spawn_pressed)
	_x = spawn_list.connect("item_mouse_selected", _on_spawn_pressed)
	if get_tree().current_scene == self:
		_on_visibility_changed()

func _on_visibility_changed():
	if !stuff_loaded:
		var root_item = spawn_list.create_item()
		root_item.set_text(0, name.capitalize())
		root_item.set_selectable(0, false)
		process_folder(directory, expand_folder_depth, root_item)
		stuff_loaded = true

func process_folder(path: String, expand: int, parent: TreeItem):
	var dir := DirAccess.open(path)

	for file in dir.get_files():
		var base_name = file
		var dot_index = base_name.rfind(".")
		if dot_index > 0:
			base_name = base_name.substr(0, dot_index).capitalize()

		file = path + "/" + file
		var item: Resource
		if mode == Mode.SCENES:
			item = ResourceLoader.load(file) as PackedScene
		elif mode == Mode.SCRIPTS:
			item = ResourceLoader.load(file) as Script
		if item:
			var file_item = spawn_list.create_item(parent)
			spawnable.append(item)
			file_item.set_text(0, base_name)
			file_item.set_selectable(0, true)
			file_item.set_metadata(0, spawnable.size() - 1)

	if expand > 0:
		for subdir in dir.get_directories():
			var dir_tree = spawn_list.create_item(parent)
			dir_tree.set_text(0, subdir.capitalize())
			dir_tree.set_selectable(0, false)
			process_folder(path + "/" + subdir, expand - 1, dir_tree)

func _on_spawn_pressed(_this = null, _that = null):
	var item = spawn_list.get_selected()
	emit_signal("spawn", spawnable[item.get_metadata(0)])
