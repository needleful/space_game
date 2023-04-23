extends Control
class_name InGameCodeEditor

enum File {
	New,
	Open,
	Save,
	SaveAs
}

enum Edit {
	Undo,
	Redo
}

var code_edit: CodeEdit:
	get: 
		if !code_edit:
			code_edit = $MarginContainer/VBoxContainer/ScrollContainer/CodeEdit
		return code_edit

var current_file: String:
	get:
		return current_file
	set(value):
		current_file = value
		var text = value if value != "" else "<New File>"
		$MarginContainer/VBoxContainer/HBoxContainer/CurrentFileLabel.text = text

var computer: Programmable:
	set(val):
		if val != computer:
			current_file = ""
		computer = val
		if computer.brain_script:
			code_edit.text = computer.brain_script.source_code

@onready var file := $MarginContainer/VBoxContainer/HBoxContainer/MenuBar/File
@onready var edit := $MarginContainer/VBoxContainer/HBoxContainer/MenuBar/Edit
@onready var file_pick := $FileDialog

func _ready():
	var file_shortcuts = {
		File.New: shortcut(KEY_N),
		File.Open: shortcut(KEY_O),
		File.Save: shortcut(KEY_S),
		File.SaveAs: shortcut(KEY_S, true)
	}
	for s in file_shortcuts:
		file.add_shortcut(file_shortcuts[s], s)
	for op in File.values():
		file.set_item_text(op, File.keys()[op].capitalize())
		
	var edit_shortcuts = {
		Edit.Undo : shortcut(KEY_Z),
		Edit.Redo: shortcut(KEY_Z, true)
	}
	for s in edit_shortcuts:
		edit.add_shortcut(edit_shortcuts[s], s)
	for op in Edit.values():
		edit.set_item_text(op, Edit.keys()[op].capitalize())

func _on_file_id_pressed(id):
	match id:
		File.New:
			# TODO: warn if the current file isn't saved
			current_file = ""
			code_edit.text = ""
		File.Open:
			file_pick.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			file_pick.popup_centered()
			current_file = await file_pick.file_selected
			var f = FileAccess.open(current_file, FileAccess.READ)
			code_edit.text = f.get_as_text()
		File.Save:
			if current_file != "":
				save()
			else:
				await get_file_save_path()
				save()
		File.SaveAs:
			await get_file_save_path()
			save()

func _on_edit_id_pressed(id):
	match id:
		Edit.Undo:
			code_edit.undo()
		Edit.Redo:
			code_edit.redo()

func get_file_save_path():
	file_pick.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_pick.popup_centered()
	current_file = await file_pick.file_selected

func save():
	var f := FileAccess.open(current_file, FileAccess.WRITE)
	f.store_string(code_edit.text)

func shortcut(keycode, shift_pressed := false, control_pressed := true) -> Shortcut:
	var res := Shortcut.new()
	var input := InputEventKey.new()
	input.pressed = true
	input.keycode = keycode
	input.shift_pressed = shift_pressed
	input.ctrl_pressed = control_pressed
	input.ctrl_pressed = true
	input.command_or_control_autoremap = true
	res.events = [input]
	return res

func log_error(text: String):
	var l := Label.new()
	l.text = text
	l.modulate = Color.RED
	$MarginContainer/VBoxContainer/messages/vbox.add_child(l)

func _on_upload_pressed():
	var sc := GDScript.new()
	sc.source_code = code_edit.text
	var res = sc.reload()
	if res != OK:
		log_error("Could not compile your code! Error code: " + str(res))
		return
	if !sc.can_instantiate():
		log_error("Can't instantiate your script!")
		return
	computer.brain_script = sc
	if computer.brain:
		computer.brain.set_script(sc)
	else:
		computer.brain = sc.new()
