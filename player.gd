extends RigidDynamicBody3D

@onready var cam_rig:Node = $cam_rig
@onready var cam_yaw:Node3D = $cam_rig/cam_yaw

var sensitivity := Vector2(1.0, 1.0)

const ACCEL_GROUND := 20.0
const MAX_RUN_SPEED := 7.0

const GRAVITY_ROT_SPEED := 40.0

func _physics_process(delta):
	var input := Input.get_vector("mv_left", "mv_right", "mv_forward", "mv_back")
	var b:Basis = cam_yaw.global_transform.basis
	apply_central_force((b.x*input.x + b.z*input.y)*ACCEL_GROUND*mass)

func _integrate_forces(state: PhysicsDirectBodyState3D):
	var up := global_transform.basis.y
	var desired_up := -PhysicsServer3D.body_get_gravity(get_rid()).normalized()
	$debug/data_1.text = "{%f, %f, %f}" % [desired_up.x, desired_up.y, desired_up.z]
	if desired_up.is_normalized():
		var angle := up.angle_to(desired_up)
		if angle > 0.001:
			var axis := up.cross(desired_up).normalized()
			var rot_xform = state.transform.rotated(axis, angle)
			rot_xform.origin = state.transform.origin
			state.transform = rot_xform
