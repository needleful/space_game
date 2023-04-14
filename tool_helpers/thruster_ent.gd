extends Node3D

@onready var particles := $GPUParticles3D
@export var power := 1000.0

func orient_to(up_direction):
	var up = global_transform.basis.y
	var angle = up.angle_to(up_direction)
	var axis = up.cross(up_direction).normalized()
	if axis.is_normalized():
		global_rotate(axis, angle)

func _physics_process(_delta):
	if Input.is_action_pressed("debug_thruster"):
		var p := get_parent() as RigidBody3D
		if p:
			var force := -global_transform.basis.y*power
			p.apply_force(force, p.global_transform.affine_inverse()*global_transform.origin)
		particles.emitting = true
	else:
		particles.emitting = false
