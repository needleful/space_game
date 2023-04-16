extends Node3D

signal activated

var original_prompt: String

@export var prompt := "Press"
var bound_vehicle := ""
var bound_input: InputEvent = null

func _ready():
	original_prompt = prompt
	set_process_input(false)

func use(_point, user: PlayerBody3D):
	if user.vehicle:
		bound_input = null
		prompt = "Press a button to bind it"
		set_process_input(true)
	else:
		emit_signal("activated")

func _input(event):
	if event.is_action_pressed("interact"):
		prompt = original_prompt
		set_process_input(false)
	elif bound_input == null:
		if event.is_pressed():
			bound_input = event
			prompt = original_prompt
	elif bound_input.is_match(event) and event.is_pressed():
		emit_signal("activated")

