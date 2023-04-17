@tool extends EditorScript

var gradient: Gradient = load("res://scripts/star_gradient.res")
const star_count := 8000
const min_distance := 60000
const distance_range := 2000
const min_scale := 15.0
const max_scale := 30.0

func _run():
	var star_mesh = get_scene().get_node("stars") as MultiMeshInstance3D
	if !star_mesh:
		return
	
	var m:MultiMesh = star_mesh.multimesh
	m.instance_count = star_count
	m.visible_instance_count = 0
	
	while m.visible_instance_count < star_count:
		var i := m.visible_instance_count
		var transform := Transform3D().scaled(
			randf_range(min_scale, max_scale)
			* Vector3(1,1,1))
		
		transform.origin = 2*Vector3(randf()-.5, randf()-.5, randf()-.5)
		if transform.origin == Vector3.ZERO:
			transform.origin = Vector3.UP
		
		transform.origin *= distance_range
		transform.origin += transform.origin.normalized() * min_distance
		transform = transform.rotated(transform.origin.normalized(), 2*PI*randf())
		
		m.set_instance_transform(i, transform)
		m.set_instance_color(i, gradient.sample(randf()))
		m.visible_instance_count += 1
