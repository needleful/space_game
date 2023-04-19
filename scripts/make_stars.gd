@tool extends EditorScript

var gradient: Gradient = load("res://scripts/star_gradient.res")
const star_count := 50000
const min_distance := 600000
const distance_range := 20000
const min_scale := 40.0
const max_scale := 300.0

func _run():
	var star_mesh = get_scene().get_node("stars") as MultiMeshInstance3D
	if !star_mesh:
		return
	
	var m:MultiMesh = star_mesh.multimesh
	m.instance_count = star_count
	m.visible_instance_count = 0
	
	while m.visible_instance_count < star_count:
		var i := m.visible_instance_count
		var scale := randf()
		scale *= scale*scale
		var transform := Transform3D()
		
		var r := randf_range(min_distance, min_distance + distance_range)
		var theta := randf()*PI*2
		var phi := acos(1 - 2 * randf())
		
		var t = Vector3(
			sin(phi) * cos(theta),
			sin(phi) * sin(theta),
			cos(phi) )
		
		transform = transform.looking_at(-t).scaled(
			lerp(min_scale, max_scale, scale)
			* Vector3(1,1,1))
		transform.origin = r*t
		m.set_instance_transform(i, transform)
		var brightness := pow(randf(), 3)
		m.set_instance_color(i, (0.1 + brightness)*gradient.sample(randf()))
		m.visible_instance_count += 1

func sqrtf(v: float):
	return sqrt(v)

func map(v: Vector3, f:Callable):
	return Vector3(f.call(v.x), f.call(v.y), f.call(v.z))
