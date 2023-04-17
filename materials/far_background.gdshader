shader_type spatial;
render_mode cull_disabled, depth_draw_never, unshaded;

uniform vec4 albedo: source_color;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	ALBEDO = albedo.rgb;
}