shader_type sky;

uniform sampler2D distant_screen;

void sky() {
	COLOR = textureLod(distant_screen, SCREEN_UV, 0).rgb;
}
