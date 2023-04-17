extends VBoxContainer

const show_cursor = true

@onready var scene = get_tree().current_scene
@onready var player: PlayerBody3D = get_parent().get_parent()

@onready var logs = $Panel/RichTextLabel

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree():
		$LineEdit.call_deferred("grab_focus")

func _on_line_edit_text_submitted(new_text):
	$LineEdit.text = ""
	write(new_text)
	var ex = Expression.new()
	var res = ex.parse(new_text)
	if res != OK:
		write_error(ex.get_error_text())
		return

	res = ex.execute([], self)
	if ex.has_execute_failed():
		write_error(ex.get_error_text())
		return

	if res is String:
		write(res)
	else:
		write(str(res), "i")

func stop():
	player.linear_velocity = Vector3.ZERO

func gravity():
	return PhysicsServer3D.body_get_direct_state(player.get_rid()).total_gravity

func write_error(string):
	logs.text += "[color=red]Error: " + string + "[/color]\n"

func write(string: String, format := ""):
	if format != "":
		string = "[%s]%s[/%s]" % [format, string, format]
	logs.text += string + "\n"

func clear():
	logs.text = ""
