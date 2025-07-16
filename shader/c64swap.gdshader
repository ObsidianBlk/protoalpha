shader_type canvas_item;

uniform int from_palette_1:hint_range(0, 15, 1) = 0;
uniform int from_palette_2:hint_range(0, 15, 1) = 0;
uniform int from_palette_3:hint_range(0, 15, 1) = 0;
uniform int from_palette_4:hint_range(0, 15, 1) = 0;
uniform int from_palette_5:hint_range(0, 15, 1) = 0;
uniform int from_palette_6:hint_range(0, 15, 1) = 0;

uniform int to_palette_1:hint_range(0, 15, 1) = 0;
uniform int to_palette_2:hint_range(0, 15, 1) = 0;
uniform int to_palette_3:hint_range(0, 15, 1) = 0;
uniform int to_palette_4:hint_range(0, 15, 1) = 0;
uniform int to_palette_5:hint_range(0, 15, 1) = 0;
uniform int to_palette_6:hint_range(0, 15, 1) = 0;

vec3 palette_color(int idx){
	vec3 vec = vec3(0.0);
	switch(idx){
		case 1:
			vec = vec3(255.0);
			break;
		case 2:
			vec = vec3(136.0, 57.0, 50.0);
			break;
		case 3:
			vec = vec3(103, 182.0, 189.0);
			break;
		case 4:
			vec = vec3(139.0, 63.0, 150.0);
			break;
		case 5:
			vec = vec3(85.0, 160.0, 73.0);
			break;
		case 6:
			vec = vec3(64.0, 49.0, 141.0);
			break;
		case 7:
			vec = vec3(191.0, 206.0, 114.0);
			break;
		case 8:
			vec = vec3(139.0, 84.0, 91.0);
			break;
		case 9:
			vec = vec3(87.0, 66.0, 0.0);
			break;
		case 10:
			vec = vec3(184.0, 105.0, 98.0);
			break;
		case 11:
			vec = vec3(80.0);
			break;
		case 12:
			vec = vec3(120.0);
			break;
		case 13:
			vec = vec3(148.0, 224.0, 137.0);
			break;
		case 14:
			vec = vec3(120.0, 105.0, 196.0);
			break;
		case 15:
			vec = vec3(159.0);
			break;
	}

	return vec / 255.0;
}

int palette_from_color(vec4 color){
	int idx = -1;
	for (int i = 0; i < 16; i++){
		idx = (distance(vec4(palette_color(i), 1.0), color) < 0.001) ? i : idx;
	}
	return idx;
}

vec4 swap_color(vec4 original){
	int from[6] = int[](from_palette_1, from_palette_2, from_palette_3, from_palette_4, from_palette_5, from_palette_6);
	int to[6] = int[](to_palette_1, to_palette_2, to_palette_3, to_palette_4, to_palette_5, to_palette_6);

	int original_idx = palette_from_color(original);
	for (int i = 0; i < 6; i++){
		if (from[i] == original_idx){
			return vec4(palette_color(to[i]), 1.0);
		}
	}
	return original;
}

void fragment() {
	COLOR = swap_color(texture(TEXTURE, UV));
}
