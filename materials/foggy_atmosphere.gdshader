shader_type spatial;
render_mode cull_front, world_vertex_coords, unshaded, depth_draw_never, depth_test_disabled;

global uniform vec3 sun_position;
uniform sampler2D fog_gradient;
uniform float outer_radius = 400.0;
uniform float surface_radius = 200.0;
uniform float max_distance = 50.0;
uniform float ambient_light_strength: hint_range(0.0, 1.0, 0.02);
uniform vec4 ambient_light_color:source_color;
uniform sampler2D screen: hint_screen_texture;
uniform sampler2D depth_tex : hint_depth_texture;
uniform sampler2D screen_albedo : hint_normal_roughness_texture;

varying vec3 world_position;
varying float shadow;

void vertex() {
	world_position = VERTEX;
	vec3 sun_direction = normalize(VERTEX - sun_position);
	shadow = clamp(0.5 + 0.5*dot(-NORMAL, sun_direction), 0.01, 0.99);
}

// Stolen from Sebastian Lague's Coding Adventure series, the Atmosphere episode
vec3 sphere_intersect(vec3 center, float radius, vec3 from, vec3 dir) {
	vec3 offset = from - center;
	float a = 1.0;
	float b = 2.0 * dot(offset, dir);
	float c = dot(offset, offset) - radius * radius;
	float d = b*b - 4.0*a*c;
	if(d > 0.0) {
		float s = sqrt(d);
		float near = max(0.0, (-b-s)/(2.*a));
		float far = (-b + s)/(2.*a);
		if (far >= 0.0) {
			return vec3(near, far, 1.0);
		}
	}
	return vec3(0.0, 0.0, 0.0); 
}

void fragment() {
	vec3 intersect = sphere_intersect(
		NODE_POSITION_WORLD,
		outer_radius,
		CAMERA_POSITION_WORLD,
		normalize(world_position - CAMERA_POSITION_WORLD)
	);
	if (intersect.z <= 0.05) {
		discard;
	}

	float depth = textureLod(depth_tex, SCREEN_UV, 0.0).r;
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
	vec3 pixel_position = upos.xyz / upos.w;
	
	float dist = min(intersect.y, length(pixel_position));
	if (dist < intersect.x) {
		discard;
	}
	float pass_through = clamp((dist - intersect.x)/max_distance, 0.0, 1.0);
	float density = 1.0;

	float s = shadow;
	vec3 ambient_light = vec3(0.0);
	if (dist < intersect.y) {
		vec3 wpos = (INV_VIEW_MATRIX * vec4(pixel_position, 1.0)).xyz;
		vec3 surf_position = wpos - NODE_POSITION_WORLD;
		float density = (length(surf_position) - surface_radius)/(outer_radius - surface_radius);
		ambient_light = clamp(1.0 - density, 0, 1)*ambient_light_strength 
			* ambient_light_color.rgb
			* texture(screen_albedo, SCREEN_UV).rgb;
	}
	vec3 color = textureLod(screen, SCREEN_UV, 0).rgb;
	vec3 fog = texture(fog_gradient, vec2(s, 0)).rgb;
	ALBEDO = mix(color + ambient_light, fog, pass_through*density);
}
