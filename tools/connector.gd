extends Tool

var queued_object: CollisionObject3D
var queued_signal: StringName
var previewing: CollisionObject3D

var wire := load("res://tool_helpers/connector/wire.tscn")

func _init():
	tool_name = "Connector"
	# mask 6
	object_mask = 32
	preview_active = true
	scroll_enabled = true

func _input(event):
	if !previewing:
		return
	if event.is_action_pressed(&"ui_up") or event.is_action_pressed(&"scroll_up"):
		scroll(-1)
	elif event.is_action_pressed(&"ui_down") or event.is_action_pressed(&"scroll_down"):
		scroll(1)

func activate(p_player):
	super.activate(p_player)
	queued_object = null
	set_process_input(true)

func cancel():
	queued_object = null

func can_fire():
	if !is_colliding():
		return false
	if !queued_object:
		return &"signals" in get_collider()
	else:
		return &"listeners" in get_collider()

func _fire(_pos, _normal, object: CollisionObject3D):
	var selected_item:int = player.ui.tool_tips.get_selected_items()[0]
	if !queued_object:
		queued_object = object
		queued_signal = previewing.signals[selected_item]
	else:
		var listener = previewing.listeners[selected_item]
		if !queued_object.is_connected(queued_signal, previewing[listener]):
			var res = queued_object.connect(queued_signal, previewing[listener])
			if res != OK:
				print_debug("Failed to connect %s.%s to %s.s: Code %d" % [
					object.name, queued_signal, queued_object.name, listener, res] )
			queued_object = null

func _preview(_pos, _normal, object:CollisionObject3D):
	player.ui.tool_tips.show()
	if !queued_object and object != previewing:
		previewing = object
		player.ui.tool_tips.clear()
		for s in previewing.get_signal_list():
			if s.name in previewing.signals:
				player.ui.tool_tips.add_item(s.name)
		player.ui.tool_tips.select(0)
	elif queued_object and object != previewing:
		previewing = object
		player.ui.tool_tips.clear()
		for m in previewing.get_method_list():
			if m.name in previewing.listeners:
				player.ui.tool_tips.add_item(m.name)
		player.ui.tool_tips.select(0)
		

func preview_exit():
	player.ui.tool_tips.hide()

func scroll(dir: int):
	if !player.ui.tool_tips.is_visible_in_tree() or !player.ui.tool_tips.is_anything_selected():
		return
	var size = player.ui.tool_tips.item_count
	var old:int = player.ui.tool_tips.get_selected_items()[0]
	var new := old+dir
	if new >= 0 and new < size:
		player.ui.tool_tips.deselect(old)
		player.ui.tool_tips.select(new)
