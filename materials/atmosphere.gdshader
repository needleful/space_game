shader_type spatial;
render_mode blend_add, cull_front, world_vertex_coords, unshaded;

uniform vec3 sun_direction = vec3(0, 1, 0);
uniform sampler2D light_gradient;
uniform float brightness = 1.0;
uniform float max_depth = 900.0;

varying float depth;
varying vec3 world_normal;

void vertex() {
	vec4 pos = VIEW_MATRIX*vec4(VERTEX, 1.0);
	depth = clamp(length(pos), 0.0, max_depth);
	world_normal = NORMAL;
}

void fragment() {
	float ndl = 0.5*dot(sun_direction, -world_normal) + 0.5;
	float light = clamp(ndl, 0.01, 0.99);
	vec3 color = brightness*texture(light_gradient, vec2(light, 0.0)).xyz;
	float d = depth/max_depth;
	d = d*d;
	ALBEDO = d*color;
}