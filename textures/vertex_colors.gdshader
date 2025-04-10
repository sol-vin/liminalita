shader_type spatial;
render_mode unshaded, cull_disabled, fog_disabled, ambient_light_disabled;

uniform bool on = true;

void fragment() {
	if (on) {
		EMISSION = COLOR.rgb;
		ALBEDO = COLOR.rgb;
		//ALBEDO = vec3(1.0, 1.0, 0.0);

	}
}