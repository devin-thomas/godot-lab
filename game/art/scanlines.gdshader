shader_type canvas_item;

void fragment() {
	float row = mod(floor(FRAGCOORD.y), 3.0);
	COLOR = vec4(0.04, 0.09, 0.13, row == 0.0 ? 0.18 : 0.0);
}
