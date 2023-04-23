extends Node3D

@onready var particles := $GPUParticles3D

var air_pressure := 0.0

const power := 750.0
const time := 2.0
var spent := false
var target_trajectory : Vector3

func _ready():
	set_physics_process(false)

func _physics_process(_delta):
	var p := get_parent() as RigidBody3D
	if p:
		var dir = lerp(
			global_transform.basis.y, target_trajectory, 0.9).normalized()
		p.apply_central_force(dir*power)

func _on_timeout():
	set_physics_process(false)
	particles.emitting = false
	spent = true

func launch():
	if spent:
		return
	set_physics_process(true)
	particles.emitting = true
	var timer := get_tree().create_timer(time)
	timer.connect("timeout", _on_timeout, CONNECT_ONE_SHOT)
	target_trajectory = global_transform.basis.y
