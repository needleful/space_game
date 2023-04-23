extends Node3D

signal pressed

var original_prompt: String

@export var prompt := "Press"
@export var bound_vehicle: NodePath
@export var bound_input: InputEvent = null

func _ready():
	original_prompt = prompt
	set_process_input(false)

func _use(_point, user: PlayerBody3D):
	if user.vehicle:
		bound_input = null
		bound_vehicle = get_path_to(user.vehicle)
		prompt = "Press a button to bind it"
		call_deferred("set_process_input", true)
	else:
		_press()

func _input(event):
	if !has_node(bound_vehicle) or !get_node(bound_vehicle).user:
		return

	if bound_input == null:
		if event.is_action_pressed("interact"):
			prompt = original_prompt
			bound_input = null
			
		elif event.is_pressed():
			bound_input = event
			prompt = original_prompt
	elif bound_input.is_match(event) and event.is_pressed():
		_press()

func _press():
	emit_signal("pressed")
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Activate")
