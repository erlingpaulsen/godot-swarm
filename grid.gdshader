shader_type spatial;
render_mode blend_mix, cull_disabled, shadows_disabled;

void fragment() {
	float v = 0.2;
	float t = 0.006;
	float lines = 0.0;
	for (float i = 0.0; i < 1.0 + t; i += 0.1) {
		lines += smoothstep(i-t, i, UV.x) * smoothstep(i+t, i, UV.x);
		lines += smoothstep(i-t, i, UV.y) * smoothstep(i+t, i, UV.y);
	}
	ALBEDO = vec3(v);
	EMISSION = 2.0*ALBEDO;
	ALPHA = lines;
}
