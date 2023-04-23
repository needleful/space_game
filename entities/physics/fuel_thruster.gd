extends CollisionObject3D
class_name Thruster

# Liters per second at max throttle
@export var fuel_consumption_rate := 1.0
@export var vector_control := false
# Newtons or some such shit
@export var power := 100

var throttle := 0.0
var vector_tilt := Vector2.ZERO
var fuel: Callable

var inputs := [
	&"throttle"
]

var resource_inputs := [
	&"fuel"
]

@onready var particles :GPUParticles3D = $particles
@onready var particle_material:ParticleProcessMaterial = particles.process_material

func _enter_tree():
	if vector_control:
		inputs.append(&"vector_tilt")

func _physics_process(_delta: float):
	if throttle == 0:# or fuel == null:
		particles.emitting = false
		return
	particles.emitting = true
	var p = get_parent()
	if p is RigidBody3D:
		var dir := global_transform.basis.y
		var pdir := particles.global_transform.basis.inverse()*dir
		particle_material.direction = -pdir
		p.apply_force(dir*throttle*power, transform.origin)
