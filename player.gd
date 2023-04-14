extends RigidBody3D

@onready var cam_rig:Node = $cam_rig

@onready var grab_cast: RayCast3D = $cam_rig/cam_pos/cam_yaw/cam_pitch/Camera3D/grab_cast
@onready var interaction_cast: RayCast3D = $cam_rig/cam_pos/cam_yaw/cam_pitch/Camera3D/interaction_cast
@onready var interaction_prompt: Label = $ui/gameing/prompt

@onready var tool_cast :RayCast3D = $cam_rig/cam_pos/cam_yaw/cam_pitch/Camera3D/tool_cast
@onready var placement_cast: RayCast3D = $cam_rig/cam_pos/cam_yaw/cam_pitch/Camera3D/placement_cast

@onready var ui := $ui

var sensitivity := Vector2(1.0, 1.0)

const ACCEL_GROUND := 35.0
const MAX_RUN_SPEED := 4.5
const VEL_JUMP := 5.0

const GRAVITY_ROT_SPEED_FACTOR := 1.0
const GRAVITY_ROT_SPEED_MAX := 10.0

## Physics interactions
# Force in newtons
const GRAB_MAX_FORCE := 700.0
# Force as a function of distance
const GRAB_FORCE_DIST := 40.0
const GRAB_DAMP_FACTOR := 10000.0
# Currently held object, or null if not grabbing
var held_object: RigidBody3D
# percentage of grab_cast away from player
var grab_distance:float
# local offset on the item where to apply the forces
var grab_offset: Vector3

var grabbed_linear_damp: float
var grabbed_angular_damp: float
var toggle_grab := false
var ground_normal : Vector3 = Vector3.UP
var ground : Node = null
var vehicle: Node = null

func _ready():
	cam_rig.first_person = true

func _input(event):
	if event.is_action_pressed("ui_toggle_spawner"):
		if ui.mode == 0:
			ui.mode = 1
		else:
			ui.mode = 0
	elif event.is_action_pressed("cam_zoom_toggle"):
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
		if held_object == null and grab_cast.is_colliding():
			var i = grab_cast.get_collider()
			if i is RigidBody3D:
				held_object = i
				
				grabbed_angular_damp = held_object.angular_damp
				grabbed_linear_damp = held_object.linear_damp
				held_object.angular_damp = GRAB_DAMP_FACTOR/(i.mass*i.mass + 1)
				held_object.linear_damp = 10/(abs(i.mass) + 1)
				var p = grab_cast.get_collision_point()
				var dist = grab_cast.target_position.length()
				var cDist = (grab_cast.global_transform.origin - p).length()
				grab_distance = cDist/dist
				grab_offset = i.global_transform.affine_inverse()*p
		elif toggle_grab and held_object:
			held_object.angular_damp = grabbed_angular_damp
			held_object.linear_damp = grabbed_linear_damp
			held_object = null
	elif !toggle_grab and held_object and event.is_action_released("phys_grab"):
		held_object.angular_damp = grabbed_angular_damp
		held_object.linear_damp = grabbed_linear_damp
		held_object = null
	elif event.is_action_pressed("fire") and tool_cast.can_fire():
		tool_cast.fire(
			tool_cast.get_collision_point(),
			tool_cast.get_collision_normal(),
			tool_cast.get_collider())
	elif event.is_action_pressed("interact") and interaction_cast.is_colliding():
		interaction_cast.get_collider().use(interaction_cast.get_collision_point(), self)
	elif event.is_action_pressed("exit") and vehicle:
		vehicle.exit()

func _physics_process(_delta):
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
	if linear_velocity != Vector3.ZERO:
		var charge := dir.project(linear_velocity)
		var steer := dir - charge
		var speed := charge.dot(linear_velocity)
		charge = charge*clamp(MAX_RUN_SPEED - speed, 0, 1)
		apply_central_force((charge + steer)*ACCEL_GROUND*mass)
	else:
		apply_central_force(dir*ACCEL_GROUND*mass)
	if held_object:
		var target_pos: Vector3 = grab_cast.global_transform*(grab_distance*grab_cast.target_position)
		var grab_pos = held_object.global_transform*grab_offset
		var grab_delta = target_pos - grab_pos
		
		var grab_force:float = clamp(
			grab_delta.length_squared()*GRAB_FORCE_DIST*held_object.mass*held_object.mass,
			0, GRAB_MAX_FORCE)
		var object_force := grab_delta.normalized()*grab_force
		
		var vel_delta := linear_velocity - held_object.linear_velocity
		var vel_force:float = clamp(
			0.5*vel_delta.length_squared()*held_object.mass*held_object.mass,
			0, GRAB_MAX_FORCE)
		var object_velocity_force := vel_force*vel_delta.normalized()
		
		held_object.apply_force(object_force, grab_offset)
		held_object.apply_central_force(object_velocity_force)
		
		apply_central_force(-object_force - object_velocity_force)
	if interaction_cast.is_colliding():
		interaction_prompt.text = interaction_cast.get_collider().prompt
		interaction_prompt.show()
	else:
		interaction_prompt.hide()

func _integrate_forces(state: PhysicsDirectBodyState3D):
	var up := global_transform.basis.y
	var gravity := state.total_gravity
	if gravity.length_squared() < 0.01:
		state.angular_velocity *= 0.99
		return
	var desired_up := -gravity.normalized()
	$ui/gameing/debug/data_1.text = "{%f, %f, %f}" % [desired_up.x, desired_up.y, desired_up.z]
	$ui/gameing/debug/data_2.text = "{%f, %f, %f}" % [linear_velocity.x, linear_velocity.y, linear_velocity.z]
	
	var angle := 0.0
	var axis := Vector3.ZERO
	if desired_up.is_normalized():
		angle = up.angle_to(desired_up)
		if angle > 0.001:
			axis = up.cross(desired_up).normalized()
	state.angular_velocity = min(
		GRAVITY_ROT_SPEED_FACTOR * gravity.length_squared(),
		GRAVITY_ROT_SPEED_MAX) * axis * angle

	ground_normal = Vector3.ZERO
	ground = null
	for i in range(state.get_contact_count()):
		var n = state.get_contact_local_normal(i)
		if n.dot(gravity) < ground_normal.dot(gravity):
			ground = state.get_contact_collider_object(i)
			ground_normal = n
	$ui/gameing/debug/data_3.text = "Contacts: " + str(state.get_contact_count())
