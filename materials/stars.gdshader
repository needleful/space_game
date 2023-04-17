shader_type spatial;
render_mode unshaded, depth_draw_never;

void fragment() {
	ALBEDO = COLOR.rgb*0.1;
}