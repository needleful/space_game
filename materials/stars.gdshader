shader_type sky;

uniform sampler2D noise;
uniform float scale1;
uniform float scale2;

void sky() {
	float stars = texture(noise, scale1*EYEDIR.xy - scale2*EYEDIR.yx).r
		+ texture(noise, scale1*EYEDIR.zx - scale2*EYEDIR.xz).r
		+ texture(noise, -scale1*EYEDIR.yz + scale2*EYEDIR.xy).r;
		
	COLOR = max(vec3(0.0), vec3(pow(stars*0.7, 32.0)));
}
