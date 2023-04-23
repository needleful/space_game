extends CollisionObject3D
class_name Programmable

@export var computer_name: String
@export var brain_script: Script

var brain: Object

var prompt: String:
	get:
		return computer_name

func _use(_point, player):
	player.ui.code_window.popup_centered()
	player.ui.code_window.title = computer_name
	player.ui.code_editor.computer = self
	player.enabled = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
