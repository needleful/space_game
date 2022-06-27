extends RigidDynamicBody3D

@onready var cam_rig:Node = $cam_rig

var sensitivity := Vector2(1.0, 1.0)

const ACCEL_GROUND := 35.0
const MAX_RUN_SPEED := 4.5
const VEL_JUMP := 5.0

const GRAVITY_ROT_SPEED := 40.0

@onready var ui := $ui

func _input(event):
	if event.is_action_pressed("ui_toggle_spawner"):
		if ui.mode != 1:
			ui.mode = 1
		else:
			ui.mode = 0
	elif event.is_action_pressed("cam_zoom_toggle"):
		cam_rig.first_person = !cam_rig.first_person
		if cam_rig.first_person:
			$MeshInstance3D.layers = 1>>11
		else:
			$MeshInstance3D.layers = 1

func _physics_process(_delta):
	var input := Input.get_vector("mv_left", "mv_right", "mv_forward", "mv_back")
	if input == Vector2.ZERO:
		physics_material_override.friction = 1.0
	else:
		physics_material_override.friction = 0.1
	var b:Basis = cam_rig.yaw.global_transform.basis
	if Input.is_action_just_pressed("mv_jump"):
		apply_central_impulse(mass*VEL_JUMP*b.y)
	var dir := (b.x*input.x + b.z*input.y)
	# As speed in the desired direction approaches max_run_speed, reduce the force
	if linear_velocity != Vector3.ZERO:
		var charge := dir.project(linear_velocity)
		var steer := dir - charge
		var speed := charge.dot(linear_velocity)
		charge = charge*clamp(MAX_RUN_SPEED - speed, 0, 1)
		apply_central_force((charge + steer)*ACCEL_GROUND*mass)
	else:
		apply_central_force(dir*ACCEL_GROUND*mass)

func _integrate_forces(state: PhysicsDirectBodyState3D):
	var up := global_transform.basis.y
	var desired_up := -PhysicsServer3D.body_get_gravity(get_rid()).normalized()
	$ui/gameing/debug/data_1.text = "{%f, %f, %f}" % [desired_up.x, desired_up.y, desired_up.z]
	$ui/gameing/debug/data_2.text = "{%f, %f, %f}" % [linear_velocity.x, linear_velocity.y, linear_velocity.z]
	
	var angle := 0.0
	var axis := Vector3.ZERO
	if desired_up.is_normalized():
		angle = up.angle_to(desired_up)
		if angle > 0.001:
			axis = up.cross(desired_up).normalized()
	state.angular_velocity = GRAVITY_ROT_SPEED*axis*angle

func _on_spawner_spawn(resource: PackedScene):
	var r = resource.instantiate()
	get_tree().current_scene.add_child(r)
	if r is Node3D:
		var location :Vector3 = (
			global_transform.origin 
			- cam_rig.yaw.global_transform.basis.z*2
			+ cam_rig.yaw.global_transform.basis.y*2)
		r.global_transform.origin = location
	
