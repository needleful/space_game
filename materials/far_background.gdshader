shader_type spatial;
render_mode cull_disabled, depth_draw_never, unshaded;
uniform float gamma : hint_range(0.5, 5.0, 0.1);

uniform sampler2D background;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	ALBEDO = pow(textureLod(background, SCREEN_UV, 0).rgb, vec3(gamma));
}