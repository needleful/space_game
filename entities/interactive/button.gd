extends Node3D

signal pressed
signal released

var holding := false

var outputs := [
	&"holding"
]

var original_prompt: String

@export var prompt := "Press"
@export var bound_vehicle: NodePath
@export var bound_input: InputEvent = null

func _ready():
	original_prompt = prompt
	set_process_input(false)
	if !has_node(bound_vehicle) or !bound_input:
		set_physics_process(false)

func _start_use(_point, user: PlayerBody3D):
	print("Press")
	if user.vehicle:
		bound_input = null
		bound_vehicle = get_path_to(user.vehicle)
		prompt = "Press a button to bind it"
		call_deferred("set_process_input", true)
	else:
		_press()

func _end_use(user: PlayerBody3D):
	print("Release")
	if !user.vehicle:
		_release()

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
			set_physics_process(true)
	elif bound_input.is_match(event) and event.is_pressed():
		_press()

func _press():
	holding = true
	emit_signal("pressed")
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Press")

func _release():
	holding = false
	emit_signal("released")
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Release")

func _physics_process(_delta):
	if !has_node(bound_vehicle):
		set_physics_process(false)
		return
	elif !get_node(bound_vehicle).user:
		return
	var should_hold := false
	if bound_input:
		if bound_input is InputEventKey:
			should_hold = Input.is_key_pressed(bound_input.keycode)
		elif bound_input is InputEventJoypadButton:
			should_hold = Input.is_key_pressed(bound_input.button_index)
		elif bound_input is InputEventMouseButton:
			should_hold = Input.is_mouse_button_pressed(bound_input.button_index)
	if should_hold != holding:
		if should_hold: _press()
		else: _release()
