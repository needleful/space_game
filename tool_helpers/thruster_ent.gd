extends CollisionObject3D
class_name ThrusterEnt

var inputs := [
	&"throttle"
]

var throttle := 0.0

@onready var particles := $GPUParticles3D
@export var power := 1000.0

func orient_to(up_direction):
	var up = global_transform.basis.y
	var angle = up.angle_to(up_direction)
	var axis = up.cross(up_direction).normalized()
	if axis.is_normalized():
		global_rotate(axis, angle)

func _physics_process(_delta):
	particles.emitting = throttle > 0.01
	var p := get_parent() as RigidBody3D
	if p:
		var force := -global_transform.basis.y*power
		p.apply_force(throttle*force, transform.origin)
