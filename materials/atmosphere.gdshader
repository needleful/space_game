shader_type spatial;
render_mode blend_add, cull_front, world_vertex_coords;

uniform sampler2D light_gradient;
uniform float brightness = 1.0;
uniform float max_depth = 900.0;

varying float depth;

void vertex() {
	vec4 pos = VIEW_MATRIX*vec4(VERTEX, 1.0);
	depth = clamp(length(pos), 0.0, max_depth);
}

void light() {
	float ndl = 0.5*dot(LIGHT, -NORMAL) + 0.5;
	float light = clamp(ndl, 0.01, 0.99);
	vec3 color = brightness*texture(light_gradient, vec2(light, 0.0)).xyz;
	float d = depth/max_depth;
	d = d*d;
	DIFFUSE_LIGHT = d*color;
}
