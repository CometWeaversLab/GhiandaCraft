shader_type spatial;

instance uniform vec3 color = vec3(1, 0, 0);

void fragment() {
	ALBEDO = color;
}
