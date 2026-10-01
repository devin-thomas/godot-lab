shader_type spatial;
render_mode unshaded;
uniform float contrast : hint_range(0.0, 1.0) = 0.5;
uniform vec4 sea : source_color = vec4(0.18, 0.47, 0.44, 1.0);
uniform vec4 brass : source_color = vec4(0.91, 0.72, 0.35, 1.0);
void fragment() {
	float bands = step(0.5, fract(UV.x * 8.0 + floor(UV.y * 8.0) * 0.5));
	ALBEDO = mix(sea.rgb, brass.rgb, mix(0.5, bands, contrast));
}
