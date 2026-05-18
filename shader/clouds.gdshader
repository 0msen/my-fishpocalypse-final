shader_type spatial;
render_mode blend_mix, cull_back;

uniform sampler2D noise_tex;
uniform float alpha_cutoff = 0.4;
uniform float speed = 0.02;

void fragment() {
	vec2 uv = UV;
	uv += TIME * vec2(speed, speed * 0.5);
	
	float n = texture(noise_tex, uv).r;
	
	float cloud = smoothstep(0.1, 0.9, n);
	cloud = cloud * cloud * (3.0 - 2.0 * cloud);
	
	ALPHA_SCISSOR_THRESHOLD = alpha_cutoff;
	ALPHA = cloud;
	ALBEDO = vec3(1.0);
}