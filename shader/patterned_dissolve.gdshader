shader_type canvas_item;

uniform sampler2D pattern_tex;
uniform int tile_pixel_size = 16;
uniform float progress:hint_range(0.0, 1.0, 0.01);

void fragment() {
	ivec2 tsize = textureSize(TEXTURE, 0);
	ivec2 pixel_offset = ivec2(UV * vec2(tsize));
	
	float uvx = float(pixel_offset.x % tile_pixel_size)/float(tile_pixel_size);
	float uvy = float(pixel_offset.y % tile_pixel_size)/float(tile_pixel_size);
	
	float alpha = step(progress, texture(pattern_tex, vec2(uvx, uvy)).r);
	vec3 color = texture(TEXTURE, UV).rgb;

	COLOR = vec4(color, alpha);
}
