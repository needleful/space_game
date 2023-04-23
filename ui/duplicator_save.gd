extends VBoxContainer

signal changed(opt_name, value)

var option_name:String
var tool:Tool

@onready var file_pick := $FileDialog

func set_option_hint(option: Dictionary):
	option_name = option.name

func set_option_value(val:String):
	$Label.text = val if val != "" else "<no file>"

func _on_save_pressed():
	await choose(FileDialog.FILE_MODE_SAVE_FILE)
	tool.save_item()

func _on_load_pressed():
	await choose(FileDialog.FILE_MODE_OPEN_FILE)
	tool.load_item()

func choose(mode):
	file_pick.file_mode = mode
	file_pick.popup_centered()
	var file = await file_pick.file_selected
	set_option_value(file)
	emit_signal("changed", option_name, file)
