shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.5;
uniform float screen_bleed : hint_range(0.0, 1.0) = 0.5;
uniform sampler2D screen_texture : hint_screen_texture;

float noise(vec2 st){
	return -1. + 2. * fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec3 static = vec3(noise(TIME * 0.25 * UV));
	vec3 screen = texture(screen_texture, SCREEN_UV).rgb;

	float screen_intensity = (screen.r + screen.g + screen.b) / 3.0;
	screen_intensity = step(0.5, screen_intensity) * screen_bleed;

	static += vec3(screen_intensity);
	COLOR = vec4(mix(screen, static, intensity), 1.0);
}
