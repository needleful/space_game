extends RigidBody3D
class_name PlayerBody3D

@onready var cam_rig:Node = $cam_rig

@onready var grab_cast: RayCast3D = $cam_rig/cam_pos/cam_yaw/cam_pitch/Camera3D/grab_cast
@onready var interaction_cast: RayCast3D = $cam_rig/cam_pos/cam_yaw/cam_pitch/Camera3D/interaction_cast
@onready var interaction_prompt: Label = $ui/gameing/prompt

@onready var tool_cast :RayCast3D = $cam_rig/cam_pos/cam_yaw/cam_pitch/Camera3D/tool_cast
@onready var placement_cast: RayCast3D = $cam_rig/cam_pos/cam_yaw/cam_pitch/Camera3D/placement_cast

@onready var usable_reticle: Node2D = $ui/gameing/reticle/crosshair_usable
@onready var can_grab_reticle: Node2D = $ui/gameing/reticle/crosshair_grab
@onready var grabbing_reticle: Node2D = $ui/gameing/reticle/crosshair_grabbing

@onready var ui := $ui

var sensitivity := Vector2(1.0, 1.0)

const ACCEL_GROUND := 35.0
const MAX_RUN_SPEED := 4.5
const VEL_JUMP := 5.0

const GRAVITY_ROT_SPEED_FACTOR := 1.0
const GRAVITY_ROT_SPEED_MAX := 10.0

var toggle_grab := false
var ground_normal : Vector3 = Vector3.UP
var ground : Node = null
var vehicle: Node = null
var air_pressure := 0.0
var gravity := Vector3.ZERO

func _ready():
	cam_rig.first_person = true
	grab_cast.user = self

func _input(event):
	if event.is_action_pressed("cam_zoom_toggle"):
		cam_rig.first_person = !cam_rig.first_person
		if cam_rig.first_person:
			$MeshInstance3D.layers = 1>>11
		else:
			$MeshInstance3D.layers = 1
	elif ui.mode == 1:
		if event.is_action_pressed("ui_right"):
			ui.spawner.current_tab += 1
		elif event.is_action_pressed("ui_left"):
			ui.spawner.current_tab -= 1
	elif event.is_action_pressed("phys_grab"):
		# Grab the object
		if grab_cast.can_fire():
			grab_cast.fire()
		elif toggle_grab and grab_cast.held_object:
			grab_cast.release()
	elif !toggle_grab and grab_cast.held_object and event.is_action_released("phys_grab"):
		grab_cast.release()
	elif event.is_action_pressed("tool_cancel"):
		tool_cast.cancel()
	elif !vehicle and event.is_action_pressed("fire") and tool_cast.can_fire():
		tool_cast.fire(
			tool_cast.get_collision_point(),
			tool_cast.get_collision_normal(),
			tool_cast.get_collider())
	elif event.is_action_pressed("interact") and interaction_cast.is_colliding():
		interaction_cast.get_collider().use(interaction_cast.get_collision_point(), self)
	elif event.is_action_pressed("exit") and vehicle:
		vehicle.exit()

func _process(_delta):
	var g = gravity/mass
	$ui/gameing/debug/data_1.text = "Gravity: {%f}" % g.length()
	$ui/gameing/debug/data_2.text = "{%f, %f, %f}" % [linear_velocity.x, linear_velocity.y, linear_velocity.z]
	$ui/gameing/debug/data_3.text = "Atmospheres: %.03f" % air_pressure
	
	usable_reticle.visible = tool_cast.can_fire()
	if grab_cast.held_object:
		can_grab_reticle.visible = false
		grabbing_reticle.visible = true
	else:
		grabbing_reticle.visible = false
		can_grab_reticle.visible = grab_cast.can_fire()

func _physics_process(delta):
	var input := Input.get_vector("mv_left", "mv_right", "mv_forward", "mv_back")
	if input == Vector2.ZERO:
		physics_material_override.friction = 1.0
	else:
		physics_material_override.friction = 0.1
	var b:Basis = cam_rig.yaw.global_transform.basis
	if ground and Input.is_action_just_pressed("mv_jump"):
		var jump_force := mass*VEL_JUMP*b.y
		apply_central_impulse(jump_force)
		if ground is RigidBody3D:
			ground.apply_impulse(
				-jump_force,
				ground.global_transform.affine_inverse() * global_transform.origin)
		ground = null
	var dir := (b.x*input.x + b.z*input.y)
	# As speed in the desired direction approaches max_run_speed, reduce the force
	var mv: Vector3
	if linear_velocity != Vector3.ZERO:
		var charge := dir.project(linear_velocity)
		var steer := dir - charge
		var speed := charge.dot(linear_velocity)
		charge = charge*clamp(MAX_RUN_SPEED - speed, 0, 1)
		mv = (charge + steer)*ACCEL_GROUND*mass
	else:
		mv = dir*ACCEL_GROUND*mass
	apply_central_force(mv)
	
	if grab_cast.held_object:
		grab_cast.update(delta)

	if interaction_cast.is_colliding():
		interaction_prompt.text = interaction_cast.get_collider().prompt
		interaction_prompt.show()
	else:
		interaction_prompt.hide()
	if get_tree().current_scene.has_method("get_gravity"):
		gravity = get_tree().current_scene.get_gravity(self)
		apply_central_force(gravity)

func _integrate_forces(state: PhysicsDirectBodyState3D):
	var up := global_transform.basis.y
	
	if gravity.length_squared() < 0.01:
		state.angular_velocity *= 0.99
		return
	var desired_up := -gravity.normalized()
	
	var angle := 0.0
	var axis := Vector3.ZERO
	if desired_up.is_normalized():
		angle = up.angle_to(desired_up)
		if angle > 0.001:
			axis = up.cross(desired_up).normalized()
	state.angular_velocity = min(
		GRAVITY_ROT_SPEED_FACTOR * max(gravity.length_squared() - 2.0, 0),
		GRAVITY_ROT_SPEED_MAX) * axis * angle

	ground_normal = Vector3.ZERO
	ground = null
	for i in range(state.get_contact_count()):
		var n = state.get_contact_local_normal(i)
		if n.dot(gravity) < ground_normal.dot(gravity):
			ground = state.get_contact_collider_object(i)
			ground_normal = n

func get_gravity():
	return gravity
