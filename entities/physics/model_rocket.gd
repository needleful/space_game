extends Node3D

@export var particles: GPUParticles3D

var on_activated:Callable = activate

var air_pressure := 0.0

const power := 750.0
const time := 2.0
var spent := false

func _ready():
	set_physics_process(false)

func activate():
	if spent:
		return
	set_physics_process(true)
	particles.emitting = true
	var timer := get_tree().create_timer(time)
	timer.connect("timeout", _on_timeout, CONNECT_ONE_SHOT)

func _physics_process(_delta):
	var p := get_parent() as RigidBody3D
	if p:
		p.apply_central_force(global_transform.basis.y*power)

func _on_timeout():
	set_physics_process(false)
	particles.emitting = false
	spent = true
