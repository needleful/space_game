extends Node
class_name PropertyConnector

var in_object : Object
var out_object: Object

var in_prop: StringName
var out_prop: StringName

func _physics_process(_delta):
	if in_object and out_object:
		in_object.set(in_prop, out_object.get(out_prop))

func attach(inode: Object, iprop: StringName, onode: Object, oprop: StringName):
	in_object = inode
	in_prop = iprop
	out_object = onode
	out_prop = oprop
	set_physics_process(true)
