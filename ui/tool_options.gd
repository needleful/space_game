extends Panel

@export var tool: Tool
@onready var widgets := $margin/scroll/widgets

const usage_flags := PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_EDITOR

const DEFAULT_WIDGETS = {
	TYPE_BOOL: preload("res://addons/fast_options/widgets/bool_widget.tscn"),
	TYPE_FLOAT: preload("res://addons/fast_options/widgets/range_widget.tscn"),
	TYPE_INT: preload("res://addons/fast_options/widgets/range_widget.tscn"),
	TYPE_COLOR: preload("res://addons/fast_options/widgets/color_widget.tscn"),
	TYPE_STRING: preload("res://addons/fast_options/widgets/string_widget.tscn")
}
const CUSTOM_WIDGETS = {
	"AudioChannel": preload("res://addons/fast_options/widgets/volume_widget.tscn")
}

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree():
		load_settings()

func load_settings():
	for c in widgets.get_children():
		c.queue_free()
	var name_label = Label.new()
	name_label.text = "%s Settings" % tool.tool_name
	widgets.add_child(name_label)
	widgets.add_child(Control.new())
	
	for property in tool.get_property_list():
		if property["usage"] & usage_flags == usage_flags:
			var l = Label.new()
			l.text = property["name"]
			widgets.add_child(l)
			widgets.add_child(create_widget(property))

func create_widget(property:Dictionary)->Control:
	var type = property.type
	if tool.has_method("get_custom_widgets"):
		var custom_widgets:Dictionary = tool.get_custom_widgets()
		if property.name in custom_widgets:
			var widg:Control = custom_widgets[property.name].instantiate()
			link_widget(property, widg)
			return widg
	if type in DEFAULT_WIDGETS:
		var widg = DEFAULT_WIDGETS[type].instantiate();
		link_widget(property, widg)
		return widg
	else:
		var value = tool.get(property.name)
		if value is Resource and value.resource_name in CUSTOM_WIDGETS:
			var widg = CUSTOM_WIDGETS[value.resource_name].instantiate()
			link_widget(property, widg)
			return widg

		var text = Label.new()
		text.text = "%s: %s (No Widget Available: '%s')" % [
			property.name, 
			type,
			str(tool.get(property.name).resource_name)
		]
		return text;

func link_widget(property, widget: Control):
	widget.set_option_hint(property)
	widget.set_option_value(tool.get(property.name))
	if "tool" in widget:
		widget.tool = tool
	if tool.has_method("set_option"):
		var _x = widget.connect("changed", tool.set_option)
	else:
		var _x = widget.connect("changed", tool.set)
