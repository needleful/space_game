extends Panel

signal spawn(item: PackedScene)

enum Mode {
	SCENES,
	SCRIPTS
}

@export var directory := "entities"
@export var expand_folder_depth := 0
@export var mode := Mode.SCENES
@onready var spawn_list:VBoxContainer = $scroll/spawn_list

var spawnable : Dictionary

func _enter_tree():
	var _x = connect("visibility_changed", self._on_visibility_changed)

func _on_visibility_changed():
	var type_hint: String
	if mode == Mode.SCENES:
		type_hint = "PackedScene"
	elif mode == Mode.SCRIPTS:
		type_hint = "Script"

	for button in spawn_list.get_children():
		if button is Button:
			var file = button.text
			if !ResourceLoader.exists(file, type_hint):
				spawnable.erase(file)
				button.queue_free()
		else:
			button.queue_free()
	process_folder(directory, expand_folder_depth)
	

func process_folder(path: String, expand: int):
	var dir := DirAccess.open(path)

	for file in dir.get_files():
		file = path + "/" + file
		if !(file in spawnable):
			var item: Resource
			if mode == Mode.SCENES:
				item = ResourceLoader.load(file) as PackedScene
			elif mode == Mode.SCRIPTS:
				item = ResourceLoader.load(file) as Script
			if item:
				spawnable[file] = item
				var b := Button.new()
				b.text = file
				b.connect("pressed", _on_spawn_pressed.bind(b))
				spawn_list.add_child(b)

	if expand > 0:
		for subdir in dir.get_directories():
			var l := Label.new()
			l.text = subdir
			spawn_list.add_child(l)
			process_folder(path + "/" + subdir, expand - 1)

	if spawn_list.get_child_count() > 0:
		spawn_list.get_child(0).grab_focus()

func _on_spawn_pressed(source: Button):
	if !(source.text in spawnable):
		print_debug("Invalid spawnable path: ", source.text)
	emit_signal("spawn", spawnable[source.text])
