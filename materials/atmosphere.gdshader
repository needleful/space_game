shader_type spatial;
render_mode blend_add, cull_front, world_vertex_coords, unshaded, depth_draw_never;

global uniform vec3 sun_position;
uniform sampler2D raleigh;
uniform float outer_radius = 400.0;

varying vec3 world_normal;
varying vec3 world_position;
varying vec3 sun_direction;

void vertex() {
	world_normal = NORMAL;
	world_position = VERTEX;
	sun_direction = normalize(world_position - sun_position);
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
	
	float d = 2.0*outer_radius;
	
	float dist = intersect.y;
	float pass_through = (dist - intersect.x)/d;
	float density = (intersect.y - intersect.x)/d;
	
	float s = clamp(0.5 + 0.5*dot(-world_normal, sun_direction), 0.01, 0.99);
	ALBEDO = texture(raleigh, vec2(s, 0)).rgb*intersect.z*pass_through*density;
}
