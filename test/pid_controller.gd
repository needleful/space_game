extends RigidBody3D

var target_y = 0.0

var kp: float
var ki: float
var kd: float

var I := 0.0

var force_factor: float = 1.0

func _ready():
	target_y = global_transform.origin.y

func _physics_process(delta):
	var max_force = force_factor*5.0
	
	var P = target_y - global_transform.origin.y
	I += delta*I
	var D = -linear_velocity.y
	var U = clamp(force_factor*(kp*P + ki*I + kd*D), -max_force, max_force)
	
	apply_central_force(Vector3.UP*U)

func _on_target_slider_changed(value):
	I = 0
	target_y = value
	$Node/debug.global_transform.origin.y = value

func _on_kp_slider_changed(value):
	kp = value

func _on_ki_slider_changed(value):
	ki = value

func _on_kd_slider_changed(value):
	kd = value

func _on_force_slider_changed(value):
	force_factor = value

func _on_mass_slider_changed(value):
	mass = value
