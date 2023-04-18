extends Node3D


var spawned_entities := []

# Called when the node enters the scene tree for the first time.
func _ready():
	$Entities.show()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		for c in spawned_entities:
			c.queue_free()
		spawned_entities = []

func _on_entities_spawn(item):
	pass
	#if item is PackedScene:
	#	var n = item.instantiate()
	#	spawned_entities.append(n)
	#	add_child(n)
