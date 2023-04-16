extends Node3D

signal origin_translated(translation)

@onready var player = $player

var planets: Array[Planet] = []
var active_planet: Planet = null

func _ready():
	for p in get_children():
		if p is Planet:
			planets.append(p)
	detect_active_planet()

func _physics_process(_delta):
	detect_active_planet()

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
