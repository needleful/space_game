extends Node

@onready var player: RigidDynamicBody3D = get_parent()
@onready var yaw:Node3D = $cam_yaw
@onready var pitch:Node3D = $cam_yaw/cam_pitch

var mouse_accum := Vector2.ZERO
var mouse_sns := Vector2(0.01, 0.01)
var analog_sns := Vector2(-0.1, 0.1)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_accum += event.relative

func _process(delta):
	yaw.global_transform.origin = player.global_transform.origin
	
	# Camera Rotation
	var mouse_aim = -mouse_accum*mouse_sns
	mouse_accum = Vector2.ZERO
	
	var analog_aim = Vector2.ZERO# Input.get_vector("cam_left", "cam_right", "cam_down", "cam_up")
	analog_aim *= analog_sns
	
	var aim : Vector2 = delta*60*player.sensitivity*(mouse_aim + analog_aim)
	#if player.invert_x:
	#	aim.x *= -1
	#if player.invert_y:
	#	aim.y *= -1
	
	yaw.rotate_y(aim.x)
	pitch.rotate_x(aim.y)
	if pitch.rotation.x > PI/2.1:
		pitch.rotation.x = PI/2.1
	elif pitch.rotation.x < -PI/2.1:
		pitch.rotation.x = -PI/2.1
	
	var up := yaw.global_transform.basis.y
	var desired_up := player.global_transform.basis.y
	var angle := up.angle_to(desired_up)
	if angle >= 0.0001:
		yaw.rotate(up.cross(desired_up).normalized(), angle)
