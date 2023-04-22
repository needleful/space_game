extends Tool

var queued_object: Object
var queued_signal: StringName
var previewing: Object

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
	
	var c = get_collider()
	if c is Programmable and c.brain:
		return true
	
	if !queued_object:
		return &"signals" in c
	else:
		return &"listeners" in c

func _fire(_pos, _normal, target):
	var object: Object = target
	if target is Programmable:
		object = target.brain
	var selected_item:int = player.ui.tool_tips.get_selected_items()[0]
	if !queued_object:
		queued_object = object
		queued_signal = object.signals[selected_item]
	else:
		var listener:StringName = object.listeners[selected_item]
		var fl:Callable = object[listener]
		
		if queued_object.is_connected(queued_signal, fl):
			queued_object.disconnect(queued_signal, fl)
		
		var res = queued_object.connect(queued_signal, fl)
		var obj_name = queued_object.name if queued_object is Node else str(queued_object)
		if res != OK:
			print_debug("Failed to connect %s.%s to %s.%s: Code %d" % [
				target.name, queued_signal, obj_name, listener, res] )
		print("Connected %s.%s to %s.%s" % [
			target.name, queued_signal, obj_name, listener
		])
		queued_object = null
		previewing = null

func _preview(_pos, _normal, target):
	var object: Object = target
	if target is Programmable:
		object = target.brain
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
