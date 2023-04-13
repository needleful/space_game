extends Control

@onready var player :Node3D = get_parent()
@onready var cam_rig = player.get_node("cam_rig")
@onready var spawner:TabContainer = $spawner
@onready var tool_prompt: String:
	get:
		return $gameing/tool.text
	set(val):
		$gameing/tool.text = val

@export var mode := 0:
	get:
		return mode
	set(value):
		if !is_inside_tree():
			mode = value
		elif value < 0 or value >= max_modes():
			print_debug("Error: bad mode ", value)
		else:
			mode = value
			for c in get_children():
				c.hide()
			var m = get_child(mode)
			m.show()
			cam_rig.enabled = !m.show_cursor
			Input.mouse_mode = (
				Input.MOUSE_MODE_CAPTURED
				if !m.show_cursor
				else Input.MOUSE_MODE_VISIBLE
				)

func _ready():
	mode = mode

func max_modes():
	return get_child_count()

func _on_entity_spawn(resource: PackedScene):
	var r = resource.instantiate()
	get_tree().current_scene.add_child(r)
	if r is Node3D:
		var item_transform := player.global_transform
		item_transform = item_transform.translated(
			item_transform.basis.z*2 
			+ item_transform.basis.y*2)
		r.global_transform = item_transform

func _on_tool_spawn(tool_script: Script):
	player.tool_cast.set_script(tool_script)
	player.tool_cast.activate(player)
