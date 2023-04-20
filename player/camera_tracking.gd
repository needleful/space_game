extends Camera3D

signal position_changed

func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		emit_signal("position_changed")
