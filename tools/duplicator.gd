extends Tool

@export var save_path: String
var saved_item: PackedScene

func _init():
	tool_name = "Duplicator"

func get_custom_widgets():
	return {
		&"save_path":load("res://ui/duplicator_save.tscn")
	}

func can_fire():
	return saved_item and is_colliding()

func can_fire2():
	return is_colliding() and get_collider() is RigidBody3D

func _fire(pos:Vector3, norm:Vector3, _object: CollisionObject3D):
	var spawn_basis = player.global_transform.basis
	var spawn_position = pos + norm*1.2
	var spawn_transform := Transform3D(spawn_basis, spawn_position)
	
	var item = saved_item.instantiate()
	get_tree().current_scene.add_child(item)
	item.global_transform = spawn_transform

func _fire2(_pos: Vector3, _norm: Vector3, object: CollisionObject3D):
	saved_item = PackedScene.new()
	set_ownership(object, object)
	var res = saved_item.pack(object)
	if res != OK:
		print_debug("Failed to save %s: %d", object.name, res)
	save_path = ""

func set_ownership(root: Node, new_owner: Node):
	for c in root.get_children():
		c.owner = new_owner
		set_ownership(c, new_owner)

func save_item():
	ResourceSaver.save(saved_item, save_path)

func load_item():
	saved_item = load(save_path) as PackedScene
