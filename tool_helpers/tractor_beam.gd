extends RayCast3D

## Physics interactions
# Force in newtons
var max_force := 2000.0
# Force as a function of distance
var force_distance := 800.0
var force_velocity := 40.0
var force_dist_accum := 800.0
var angular_damp := 0.5

var held_object: RigidBody3D
# As a percent of the total cast distance
var grab_distance:float
# Local position grabbed on the object
var grab_offset: Vector3

var grabbed_linear_damp: float
var grabbed_angular_damp: float
var toggle_grab := false
var error_accum := Vector3.ZERO
var held_angular_damp := 0.0

var user: RigidBody3D

func can_fire():
	return is_colliding() and get_collider() is RigidBody3D

func fire():
	held_object = get_collider() as RigidBody3D
	grabbed_angular_damp = held_object.angular_damp
	grabbed_linear_damp = held_object.linear_damp
	var p = get_collision_point()
	var dist = target_position.length()
	var cDist = (global_transform.origin - p).length()
	grab_distance = cDist/dist
	grab_offset = held_object.global_transform.affine_inverse()*p
	held_angular_damp = held_object.angular_damp
	held_object.angular_damp = 400

func release():
	if held_object:
		held_object.angular_damp = held_angular_damp
	held_object = null
	error_accum = Vector3.ZERO

func update(delta):
	var target_pos: Vector3 = global_transform*(grab_distance*target_position)
	var grab_pos := held_object.global_transform*grab_offset
	var grab_delta := target_pos - grab_pos
	
	error_accum += grab_delta*delta
	
	var grab_force:float = (force_distance
		* grab_delta.length()
		* held_object.mass)
	
	var object_force := (
		grab_delta * grab_force
		+ force_dist_accum * held_object.mass * error_accum)

	var vel_delta := user.linear_velocity - held_object.linear_velocity
	var vel_force:float = (force_velocity
		* vel_delta.length()
		*	held_object.mass)

	object_force += vel_force*vel_delta.normalized()
	
	if object_force.length_squared() > max_force*max_force:
		object_force = object_force.normalized()*max_force
	
	held_object.apply_central_force(object_force)
	user.apply_central_force(-object_force)
