extends Control
class_name UI

enum Mode {
	Gameing,
	Spawner,
	Console
}

@onready var player :Node3D = get_parent()
@onready var cam_rig = player.get_node("cam_rig")
@onready var spawner:TabContainer = $spawner
@onready var tool_tips: ItemList = $gameing/tool_tips
@onready var tool_prompt: String:
	get:
		return $gameing/tool.text
	set(val):
		$gameing/tool.text = val

@export var mode := Mode.Gameing:
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

func _input(event):
	if event.is_action_pressed("ui_toggle_spawner"):
		if mode == Mode.Gameing:
			mode = Mode.Spawner
		else:
			mode = Mode.Gameing
	elif event.is_action_pressed("debug_console"):
		if mode == Mode.Gameing:
			mode = Mode.Console
			get_tree().paused = true
		else:
			mode = Mode.Gameing
			get_tree().paused = false

func _ready():
	mode = mode

func max_modes():
	return get_child_count()

func _on_entity_spawn(resource: PackedScene):
	var r = resource.instantiate()
	get_tree().current_scene.add_child(r)
	if r is Node3D:
		var ibasis := player.global_transform.basis
		var cast_point: Vector3
		if player.placement_cast.is_colliding():
			cast_point = player.placement_cast.get_collision_point() + ibasis.y
		else:
			var t:Transform3D = player.placement_cast.global_transform
			cast_point = t.origin + t.basis*player.placement_cast.target_position + ibasis.y
		var item_transform := Transform3D(ibasis, cast_point)
		r.global_transform = item_transform

func _on_tool_spawn(tool_script: Script):
	player.tool_cast.set_script(tool_script)
	player.tool_cast.activate(player)
