extends Panel

signal spawn(path: PackedScene)

@export var directory := "entities"

@onready var spawn_list:VBoxContainer = $spawn_list

var spawnable : Dictionary

func show():
	super.show()
	var dir := Directory.new()
	dir.change_dir(directory)
	
	var new_entities: Array[String] = []
	for file in dir.get_files():
		file = directory + "/" + file
		if !(file in spawnable):
			var scene := ResourceLoader.load(file) as PackedScene
			if scene:
				spawnable[file] = scene
				new_entities.append(file)
	for button in spawn_list.get_children():
		if button is Button:
			var file = button.text
			if !ResourceLoader.exists(file, "PackedScene"):
				spawnable.erase(file)
				button.queue_free()
		else:
			button.queue_free()
	for e in new_entities:
		var b := Button.new()
		b.text = e
		b.connect("pressed", self._on_spawn_pressed, [b])
		spawn_list.add_child(b)
	
	if spawn_list.get_child_count() > 0:
		spawn_list.get_child(0).grab_focus()

func _on_spawn_pressed(source: Button):
	if !(source.text in spawnable):
		print_debug("Invalid spawnable path: ", source.text)
	emit_signal("spawn", spawnable[source.text])
