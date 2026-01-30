extends Node

signal origin_translated(translation)
signal base_velocity_changed(velocity_change)

@onready var player := $player
@onready var stars := $stars

var planets: Array[Planet] = []
var velocities: PackedVector3Array = []
var orbit_angle: PackedFloat64Array = []
var spin_angle: PackedFloat64Array = []
var active_planet: Planet = null
var active_velocity: Vector3
var star_rotation := PI*2/(51*60)

# Fake gravitational constant
const G := 1.0e-5

func _ready():
	for p in get_children():
		if p is Planet:
			planets.append(p)
			if p.orbit:
				var dir:Vector3 = (p.global_transform.origin 
					- p.orbit.global_transform.origin).normalized()
				p.orbit_axis = Vector3.UP.slide(dir).normalized()
				p.spin_axis = p.global_transform.basis.y
				orbit_angle.append(2*PI/(p.orbit_period*60.0))
				spin_angle.append(2*PI/(p.spin_period*60.0))
			else:
				p.spin_axis = Vector3.UP
				p.orbit_axis = Vector3.UP
				orbit_angle.append(0)
				spin_angle.append(0)
	velocities.resize(planets.size())
	detect_active_planet()
	#var s: ShaderMaterial = $WorldEnvironment.environment.sky.sky_material
	#var vt := ViewportTexture.new()
	#vt.viewport_path = $far_viewport/far_camera.get_path()
	#s.set_shader_parameter('background', vt)

func _physics_process(delta):
	stars.rotate_x(star_rotation*delta)
	# Note! this depends on the order of the nodes
	# Bodies should always come after the body they orbit
	active_velocity = Vector3.ZERO
	var global_spin_axis := Vector3.ZERO
	var global_spin_angle := 0.0
	for i in planets.size():
		var p:Planet = planets[i]
		var o := p.orbit
		if !o:
			velocities[i] = Vector3.ZERO
			continue
		var orbit_movement := velocities[planets.find(o)]
		var d1 := p.global_transform.origin - o.global_transform.origin
		var d2 := d1.rotated(p.orbit_axis, orbit_angle[i])
		velocities[i] = (d2 - d1) + orbit_movement
		if p == active_planet:
			active_velocity = velocities[i]
			global_spin_axis = p.spin_axis
			global_spin_angle = spin_angle[i]
	for i in planets.size():
		var p:Planet = planets[i]
		var spin_velocity := Vector3.ZERO
		if p != active_planet:
			p.global_rotate(p.spin_axis, delta*spin_angle[i])
			if global_spin_angle: 
				var d1 := p.global_transform.origin - active_planet.global_transform.origin
				var d2 := d1.rotated(global_spin_axis, -global_spin_angle)
				spin_velocity = d1 - d2
				p.global_rotate(global_spin_axis, -delta*global_spin_angle)
		p.global_translate(delta*(velocities[i] - active_velocity + spin_velocity))
	if global_spin_angle:
		stars.global_rotate(global_spin_axis, delta*global_spin_angle)
	detect_active_planet()
	for c in get_children():
		if c is RigidBody3D and !(c is PlayerBody3D):
			c.apply_central_force(get_gravity(c))

func get_gravity(c: RigidBody3D) -> Vector3:
	var force := Vector3.ZERO
	for p in planets:
		var d:Vector3 = p.global_transform.origin - c.global_transform.origin 
		var rr:float = p.surface_radius*p.surface_radius
		var grav = G*(d.length_squared() - rr)
		var acceleration = p.gravitation/(1.0 + max(grav, 0))
		force += d.normalized()*acceleration*c.mass
	return force

func detect_active_planet():
	var closest_planet: Planet = null
	# Square distance for a planet to be active
	var dsq:float = 3000*3000
	for p in planets:
		var d = (p.global_transform.origin - player.global_transform.origin).length_squared()
		if d < dsq:
			if closest_planet and closest_planet.active:
				closest_planet.active = false
			closest_planet = p
			dsq = d
		elif p.active:
			p.active = false
	if closest_planet != active_planet:
		var old_active_planet := active_planet
		active_planet = closest_planet
		if active_planet:
			var origin := active_planet.global_transform.origin
			var a = planets.find(active_planet)
			var new_vel := velocities[a]
			var new_spin := spin_angle[a]*active_planet.spin_axis
			var old_spin := Vector3.ZERO
			if old_active_planet:
				old_spin = old_active_planet.spin_axis*spin_angle[planets.find(old_active_planet)]
			if origin.length_squared() > 100*100:
				translate_origin(-origin, active_velocity - new_vel, old_spin - new_spin)
			active_planet.active = true
			print("Active planet: ", active_planet.name)
		else:
			print("No active planets")
	
func translate_origin(translation:Vector3, velocity_change: Vector3, rotation_change: Vector3):
	for c in get_children():
		if c is Node3D:
			c.global_translate(translation)
		if c is CharacterBody3D:
			c.velocity += velocity_change
		if c is RigidBody3D:
			c.linear_velocity += velocity_change
			c.angular_velocity += rotation_change
	emit_signal("origin_translated", translation)
	emit_signal("base_velocity_changed", velocity_change)
