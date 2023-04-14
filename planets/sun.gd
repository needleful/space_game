@tool
extends DirectionalLight3D

func _ready():
	RenderingServer.global_shader_parameter_set("sun_position", global_transform.origin)
