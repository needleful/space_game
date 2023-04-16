extends Node3D

signal activated

var original_prompt: String

@export var prompt := "Press"
var bound_vehicle = null
var bound_input: InputEvent = null

func _ready():
	original_prompt = prompt
	set_process_input(false)

func use(_point, user: PlayerBody3D):
	if user.vehicle:
		bound_input = null
		bound_vehicle = user.vehicle
		prompt = "Press a button to bind it"
		call_deferred("set_process_input", true)
	else:
		activate()

func _input(event):
	if !bound_vehicle or !bound_vehicle.user:
		return

	if bound_input == null:
		if event.is_action_pressed("interact"):
			prompt = original_prompt
			bound_input = null
			
		elif event.is_pressed():
			bound_input = event
			prompt = original_prompt
	elif bound_input.is_match(event) and event.is_pressed():
		activate()

func activate():
	emit_signal("activated")
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Activate")
