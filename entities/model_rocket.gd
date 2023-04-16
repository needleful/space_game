extends Node3D

@export var particles: GPUParticles3D

var on_activated:Callable = activate

var air_pressure := 0.0

const power := 750.0
const time := 2.0
const self_righting_torque := 12.0

var target_bearing := Vector3.UP
var spent := false

func _ready():
	set_physics_process(false)

func activate():
	if spent:
		return
	set_physics_process(true)
	particles.emitting = true
	target_bearing = global_transform.basis.y
	var timer := get_tree().create_timer(time)
	timer.connect("timeout", _on_timeout, CONNECT_ONE_SHOT)

func _physics_process(_delta):
	var p := get_parent() as RigidBody3D
	if p:
		# TODO: make this apply the force in the proper location with some form of stabilization
		p.apply_central_force(target_bearing*power)

func _on_timeout():
	set_physics_process(false)
	particles.emitting = false
	spent = true
