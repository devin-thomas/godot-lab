shader_type canvas_item;
uniform bool crt_enabled = false;
void fragment() {
	vec4 source = texture(TEXTURE, UV);
	float line = crt_enabled ? mix(0.82, 1.0, step(0.5, fract(UV.y * 144.0))) : 1.0;
	COLOR = vec4(source.rgb * line, source.a);
}
