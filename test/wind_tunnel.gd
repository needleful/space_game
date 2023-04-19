extends Area3D

var vel := Vector3.UP
#var air_angular_damp := 2.0
var density := 1.0
var drag_const := 0.4
const min_velocity := 2.0

# Scratch space for 3D convex hull calculations
var points2d := PackedVector2Array()

func _physics_process(_delta):
	for b in get_overlapping_bodies():
		if b is RigidBody3D:
			var u = vel-b.linear_velocity
			if u.length_squared() > min_velocity*min_velocity:
				apply_drag(b, u, density)

# u: flow velocity
# p: density
func apply_drag(body: RigidBody3D, u: Vector3, p: float):
	var dir := u.normalized()
	# A basis with the X axis in the direction of our velocity
	# other axes are arbitrary perpendicular vectors.
	# This probably works.
	var ubasis := Basis(dir, Vector3(dir.y, -dir.z, dir.x), Vector3(-dir.z, dir.x, -dir.y))
	
	for c in body.get_children():
		var shape := c as CollisionShape3D
		if shape and !shape.disabled:
			var center := Vector3.ZERO
			var area := 0.0
			# The only confirmed method of calculating the drag coefficient
			# is to first calculate the drag of the object in a wind tunnel
			# and then divide by the other parameters.
			# I was wondering why engines don't simulate drag...
			var coeff := 1.0
			if shape.shape is SphereShape3D:
				coeff = 0.47
				center = shape.transform.origin
				area = PI*shape.shape.radius*shape.shape.radius
			elif shape.shape is CylinderShape3D:
				coeff = 0.7
				var r: float = shape.shape.radius
				var h: float = shape.shape.height
				var theta:float = abs(shape.global_transform.basis.y.angle_to(dir))
				center = shape.transform.origin
				area = sin(theta)*2*r*h + cos(theta)*PI*r*r
			elif shape.shape is CapsuleShape3D:
				coeff = 0.6
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
				# Get a basis to go from shape-local space to a space with U as the X axis
				var iubasis := ubasis.inverse()*shape.global_transform.basis
				var points3d:PackedVector3Array = shape.shape.points
				points2d.resize(points3d.size())
				for i in points3d.size():
					var v := points3d[i]
					var vu := iubasis*v
					points2d[i] = Vector2(vu.y, vu.z)
				points2d = Geometry2D.convex_hull(points2d)
				area = 0.0
				var center2d := Vector2.ZERO
				var segsum := 0.0
				for i in points2d.size():
					var p1 := points2d[i]
					var i2 := i+1
					if i2 == points2d.size():
						i2 = 0
					var p2 := points2d[i2]
					var l := (p1 - p2).length()
					segsum += l
					center2d += 0.5*l*(p1 - p2)
					area += 0.5*(p1.x*p2.y - p1.y*p2.x)
				center2d /= segsum
				center = (
					shape.global_transform.basis.inverse()
					* ubasis
					* Vector3(0, center2d.x, center2d.y))

			var drag = 0.5 * p * u * u.length() * coeff * area
			body.apply_force(drag_const*drag, center)

func _on_slider_value_changed(value):
	vel = Vector3.UP*value
	$GPUParticles3D.process_material.initial_velocity_max = value*1.2
	$GPUParticles3D.process_material.initial_velocity_min = value*0.8
