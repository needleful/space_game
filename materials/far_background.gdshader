shader_type sky;
uniform float gamma : hint_range(0.5, 5.0, 0.1) = 1.0;

uniform sampler2D background: filter_nearest;

void sky() {
	COLOR = pow(textureLod(background, SCREEN_UV, 0).rgb, vec3(gamma));
}