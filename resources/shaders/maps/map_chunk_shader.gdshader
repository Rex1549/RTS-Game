shader_type spatial;
//render_mode wireframe;
uniform sampler2D diff;

void vertex() {
	// vertex shader code goes here
}

void fragment() {
	// fragment shader code goes here
	ALBEDO = texture(diff, UV).xyz;
}
