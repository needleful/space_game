extends Node

@onready var player: RigidDynamicBody3D = get_parent()
@onready var pos :Node3D = $cam_pos
@onready var yaw:Node3D = $cam_pos/cam_yaw
@onready var pitch:Node3D = $cam_pos/cam_yaw/cam_pitch
@onready var camera:Node3D = pitch.get_node("Camera3D")

@onready var pitch_pos := pitch.transform.origin
@onready var cam_pos:Vector3 = camera.transform.origin

var mouse_accum := Vector2.ZERO
var mouse_sns := Vector2(0.01, 0.01)
var analog_sns := Vector2(-0.1, 0.1)

const ZOOM_SWITCH_TIME := 0.2

#var tween : Tween

var first_person := false:
	set(value):
		first_person = value
		if !is_inside_tree():
			return
		else:
			var tween = get_tree().create_tween()
			tween.set_parallel(true)
			tween.set_ease(Tween.EASE_OUT)
			if first_person:
				tween.tween_property(pitch,"transform:origin", Vector3(0, 1, 0), ZOOM_SWITCH_TIME)
				tween.tween_property(camera, "transform:origin", Vector3(0,0,0), ZOOM_SWITCH_TIME)
			else:
				tween.tween_property(pitch, "transform:origin", pitch_pos, ZOOM_SWITCH_TIME)
				tween.tween_property(camera, "transform:origin", cam_pos, ZOOM_SWITCH_TIME)
			

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_accum += event.relative

func _process(delta):
	# Global movement
	pos.global_transform.origin = player.global_transform.origin
	var up := pos.global_transform.basis.y
	var desired_up := player.global_transform.basis.y
	var angle := up.angle_to(desired_up)
	if angle >= 0.0001:
		pos.global_rotate(up.cross(desired_up).normalized(), angle)
	
	# Camera Rotation
	var mouse_aim = -mouse_accum*mouse_sns
	mouse_accum = Vector2.ZERO
	
	var analog_aim = Input.get_vector("cam_left", "cam_right", "cam_down", "cam_up")
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
	
