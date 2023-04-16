extends Node3D

signal origin_translated(translation)

@onready var player = $player

var planets: Array[Planet] = []
var active_planet: Planet = null
# Fake gravitational constant
const G := 1.0e-5

func _ready():
	for p in get_children():
		if p is Planet:
			planets.append(p)
	detect_active_planet()

func _physics_process(_delta):
	detect_active_planet()
	for c in get_children():
		if c is RigidBody3D and !(c is PlayerBody3D):
			c.apply_central_force(get_gravity(c))

func get_gravity(c: RigidBody3D) -> Vector3:
	var force := Vector3.ZERO
	for p in planets:
		var d := p.global_transform.origin - c.global_transform.origin 
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
		active_planet = closest_planet
		if active_planet:
			var origin := active_planet.global_transform.origin
			if origin.length_squared() > 100*100:
				translate_origin(-origin)
			active_planet.active = true
			print("Active planet: ", active_planet.name)
		else:
			print("No active planets")
	
func translate_origin(translation:Vector3):
	for c in get_children():
		if c is Node3D:
			c.global_translate(translation)
	emit_signal("origin_translated", translation)
