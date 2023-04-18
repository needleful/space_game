extends CharacterBody3D

@onready var vehicle := $vehicle

func _physics_process(delta):
	if !vehicle.user:
		return
	var p = vehicle.user as PlayerBody3D
	var c = p.cam_rig.camera as Camera3D
	
	var move = Input.get_vector("mv_left", "mv_right", "mv_forward", "mv_back")
	var up = Input.get_axis("fire", "fire2")
	
	var b:Basis = c.global_transform.basis
	var movement = b.x*move.x + b.z*move.y - b.y*up
	velocity += 30*movement*delta
	move_and_slide()
