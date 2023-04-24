extends Tool

enum Mode {
	Signal,
	Property
}

var queued_object: Object
var queued_output: Dictionary
var previewing: Object
var mode := Mode.Signal

var wire := load("res://tool_helpers/connector/wire.tscn")

func _init():
	tool_name = "Connector"
	# mask 6
	object_mask = 32
	preview_active = true

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
	previewing = null

func can_fire():
	if !is_colliding():
		return false
	
	var c = get_collider()
	if c is Programmable and c.brain:
		c = c.brain
	var scr:Script = c.get_script()
	if !scr:
		return false
	
	if !queued_object:
		for m in scr.get_script_signal_list():
			if !m.name.begins_with("_") and !m.name.begins_with("@"):
				return true
		if &"outputs" in c:
			return true
		return false
	else:
		if mode == Mode.Signal:
			for m in scr.get_script_method_list():
				if !m.name.begins_with("_") and !m.name.begins_with("@"):
					return true
		elif mode == Mode.Property:
			if &"inputs" in c:
				return true
		return false

func _fire(_pos, _normal, target):
	var selected := player.ui.tool_tips.get_selected_items()
	if selected.is_empty():
		return
	var selected_item:int = selected[0]

	var object: Object = target
	if target is Programmable:
		object = target.brain
	if !queued_object:
		queued_object = object
		var s := signals(object)
		
		if selected_item < s.size():
			queued_output = s[selected_item]
			mode = Mode.Signal
		else:
			selected_item -= s.size()
			for prop in object.get_script().get_script_property_list():
				if prop.name == object.outputs[selected_item]:
					queued_output = prop
			mode = Mode.Property
	else:
		if mode == Mode.Signal:
			var listener:StringName = listeners(object)[selected_item].name
			var fl:Callable = object[listener]
			
			if queued_object.is_connected(queued_output.name, fl):
				queued_object.disconnect(queued_output.name, fl)
			
			var res = queued_object.connect(queued_output.name, fl, CONNECT_PERSIST)
			var obj_name = queued_object.name if queued_object is Node else str(queued_object)
			if res != OK:
				print_debug("Failed to connect %s.%s to %s.%s: Code %d" % [
					target.name, queued_output, obj_name, listener, res] )
			print("Connected %s.%s to %s.%s" % [
				target.name, queued_output, obj_name, listener
			])
		elif mode == Mode.Property:
			var con = PropertyConnector.new()
			target.add_child(con)
			con.attach(object, object.inputs[selected_item],
				queued_object, queued_output.name)
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
		for s in signals(previewing):
			var id := player.ui.tool_tips.add_item(s.name, load("res://ui/connector/icon_signal.png"))
			player.ui.tool_tips.set_item_disabled(id, false)
		if &"outputs" in previewing:
			for o in previewing.outputs:
				var id := player.ui.tool_tips.add_item(o, load("res://ui/connector/icon_property_out.png"))
				player.ui.tool_tips.set_item_disabled(id, false)
		player.ui.tool_tips.select(0)
	elif queued_object and object != previewing:
		previewing = object
		player.ui.tool_tips.clear()
		var first_valid_index := -1
		if mode == Mode.Signal:
			var i := 0
			for m in listeners(previewing):
				var id := player.ui.tool_tips.add_item(m.name, load("res://ui/connector/icon_listener.png"))
				var compat = compatible_methods(m, queued_output)
				if compat and first_valid_index < 0:
					first_valid_index = i
				player.ui.tool_tips.set_item_disabled(id, !compat)
				i += 1
		elif mode == Mode.Property:
			for i in previewing.inputs.size():
				var m:StringName = previewing.inputs[i]
				var id := player.ui.tool_tips.add_item(m, load("res://ui/connector/icon_property_in.png"))
				var input_property
				for prop in previewing.get_script().get_script_property_list():
					if prop.name == m:
						input_property = prop
						break
				var compat = compatible_properties(input_property, queued_output)
				if compat and first_valid_index < 0:
					first_valid_index = i
				player.ui.tool_tips.set_item_disabled(id, !compat)
		player.ui.tool_tips.select(first_valid_index)

func signals(object: Object) -> Array:
	var s := []
	for c in object.get_script().get_script_signal_list():
		if !c.name.begins_with("_") and !c.name.begins_with("@"):
			s.append(c)
	return s

func listeners(object: Object) -> Array:
	var l := []
	for c in object.get_script().get_script_method_list():
		if !c.name.begins_with("_") and !c.name.begins_with("@"):
			l.append(c)
	return l

func preview_exit():
	player.ui.tool_tips.hide()

func scroll(dir: int):
	if !player.ui.tool_tips.is_visible_in_tree() or !player.ui.tool_tips.is_anything_selected():
		return
	var size = player.ui.tool_tips.item_count
	var old:int = player.ui.tool_tips.get_selected_items()[0]
	var new := old+dir
	while new < size and player.ui.tool_tips.is_item_disabled(new):
		new += dir
	if new >= 0 and new < size:
		player.ui.tool_tips.deselect(old)
		player.ui.tool_tips.select(new)

func compatible_methods(method: Dictionary, sig: Dictionary):
	if sig.args.size() > method.args.size():
		return false
	elif method.args.size() - method.default_args.size() > sig.args.size():
		return false
	for i in sig.args.size():
		if !compatible_properties(method.args[i], sig.args[i]):
			return false
	return true

func compatible_properties(input:Dictionary, output:Dictionary):
	if output.type == TYPE_BOOL and (input.type == TYPE_INT or input.type == TYPE_FLOAT):
		return true
	if input.type == TYPE_NIL or output.type == TYPE_NIL:
		return true
	return input.type == output.type
