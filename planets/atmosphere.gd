extends Area3D

@export var surface_radius: float = 200
@export var outer_radius: float = 400
@export var atmospheres_at_surface:float = 1.0

var drag_const := 0.4
var min_velocity := 2.0
const angular_damp_factor := 1.0

func _ready():
	connect("body_exited", _on_body_exited)

func _on_body_exited(body):
	if "air_pressure" in body:
		body.air_pressure = 0.0

func density_at_point(point: Vector3) -> float:
	var c:= outer_radius - surface_radius
	var d := (point - global_transform.origin).length() - surface_radius
	return atmospheres_at_surface*clamp(1.0 - d/c, 0, 1.0)

func _physics_process(_delta):
	for b in get_overlapping_bodies():
		var d = density_at_point(b.global_transform.origin)
		if "air_pressure" in b:
			b.air_pressure = d
		if b is RigidBody3D:
			# TODO: wind goes here
			var change = -b.linear_velocity
			if change.length_squared() > min_velocity*min_velocity:
				var density = d
				var drag = 0.5*density*drag_const*change.length()*change
				apply_drag(b, drag, change.normalized())
			# TODO: somehow factor into drag?
			# Also there's a bug with torque
			#b.apply_torque(-b.angular_velocity*d*angular_damp_factor)
			
func apply_drag(body: RigidBody3D, drag: Vector3, dir: Vector3):
	for c in body.get_children():
		var shape := c as CollisionShape3D
		if shape and !shape.disabled:
			var center := Vector3.ZERO
			var area := 0.0
			if shape.shape is SphereShape3D:
				center = shape.transform.origin
				area = PI*shape.shape.radius*shape.shape.radius
			elif shape.shape is CylinderShape3D:
				var r: float = shape.shape.radius
				var h: float = shape.shape.height
				var theta:float = abs(shape.global_transform.basis.y.angle_to(dir))
				center = shape.transform.origin
				area = sin(theta)*2*r*h + cos(theta)*PI*r*r
			elif shape.shape is CapsuleShape3D:
				var r: float = shape.shape.radius
				var h: float = shape.shape.height
				var theta:float = abs(shape.global_transform.basis.y.angle_to(dir))
				center = shape.transform.origin
				area = sin(theta)*2*r*h + PI*r*r
			elif shape.shape is BoxShape3D:
				var w:float = shape.shape.size.x
				var h:float = shape.shape.size.y
				var d:float = shape.shape.size.z
				var cx:float = abs(shape.global_transform.basis.x.dot(dir))
				var cy:float = abs(shape.global_transform.basis.y.dot(dir))
				var cz:float = abs(shape.global_transform.basis.z.dot(dir))
				center = shape.transform.origin
				area = w*h*cz + w*d*cy + h*d*cx
			body.apply_force(drag*area, center)
