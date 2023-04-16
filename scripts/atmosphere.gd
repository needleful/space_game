extends Area3D

@export var surface_radius: float = 200
@export var outer_radius: float = 400
@export var atmospheres_at_surface:float = 1.0

func density_at_point(point: Vector3) -> float:
	var c:= outer_radius - surface_radius
	var d := (point - global_transform.origin).length() - surface_radius
	return atmospheres_at_surface*clamp(1.0 - d/c, 0, 1.0)

func _physics_process(_delta):
	for b in get_overlapping_bodies():
		if "air_pressure" in b:
			b.air_pressure = density_at_point(b.global_transform.origin)
