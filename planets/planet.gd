extends Node3D
class_name Planet

@export var gravitation := 15.0
@export var surface_radius := 200.0
@export var active_only:Array[Node]
@export var orbit: Planet
var orbit_axis: Vector3
var spin_axis: Vector3

@export_range(1.0, 600.0, 1.0) var spin_period := 15.0
@export_range(1.0, 1800.0, 1.0) var orbit_period := 120.0

var sealed_nodes := {}

var active: bool = true:
	set(val):
		active = val
		if !is_inside_tree():
			return
		elif !active:
			print("Deactivating ", name)
			for n in active_only:
				sealed_nodes[n] = {
					"transform":n.transform,
					"parent":n.get_parent()
				}
				n.get_parent().remove_child(n)
		else:
			for n in sealed_nodes:
				var d = sealed_nodes[n]
				d.parent.add_child(n)
				n.transform = d.transform
	get:
		return active
