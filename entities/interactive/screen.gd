extends CharacterBody3D

@onready var screen := $screen
@onready var viewport := $SubViewport
@onready var dataLabel := $SubViewport/Panel/Label

var inputs := [
	&"value"
]

var value:
	set(v):
		value = v
		if is_inside_tree():
			dataLabel.text = str(v)
