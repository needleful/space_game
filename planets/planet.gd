extends Node3D
class_name Planet

@export var active_only:Array[Node]

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
