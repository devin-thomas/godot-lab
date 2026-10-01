shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

uniform sampler2D atlas : source_color, filter_nearest, repeat_enable;
uniform vec4 tint : source_color = vec4(0.4, 0.8, 0.7, 1.0);
uniform float vertex_strength : hint_range(0.0, 1.0) = 1.0;
uniform bool authored_only = true;
varying vec4 painted_color;

void vertex() {
	painted_color = COLOR;
}

void fragment() {
	vec3 paint = texture(atlas, UV).rgb * tint.rgb;
	paint *= mix(vec3(1.0), painted_color.rgb, vertex_strength);
	ALBEDO = authored_only ? vec3(0.0) : paint;
	EMISSION = authored_only ? paint : vec3(0.0);
	ROUGHNESS = 1.0;
}
