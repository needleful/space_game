extends Area3D

var vel := Vector3.UP
#var air_angular_damp := 2.0
var density := 1.0
var drag_const := 0.4
const min_velocity := 2.0

func _physics_process(_delta):
	for b in get_overlapping_bodies():
		if b is RigidBody3D:
			var change = vel - b.linear_velocity
			if change.length_squared() > min_velocity*min_velocity:
				var drag = 0.5*density*drag_const*change.length()*change
				apply_drag(b, drag, change.normalized())
			#c.angular_damp = air_angular_damp

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
			elif shape.shape is ConvexPolygonShape3D:
				var points:PackedVector3Array = shape.shape.points
			body.apply_force(drag*area, center)

func _on_slider_value_changed(value):
	vel = Vector3.UP*value
	$GPUParticles3D.process_material.initial_velocity_max = value*1.2
	$GPUParticles3D.process_material.initial_velocity_min = value*0.8
