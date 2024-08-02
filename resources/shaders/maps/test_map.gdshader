shader_type spatial;

uniform sampler2D sand_diff;
uniform sampler2D sand_norm;
uniform sampler2D sand_rough;

uniform sampler2D cliff_diff;
uniform sampler2D cliff_norm;
uniform sampler2D cliff_rough;


void fragment() {
	float fac = clamp(dot(NORMAL.rgb, vec3(0.0,1.0,0.0)) - 0.2, 0.0, 1.0);
	
	ALBEDO = fac * texture(sand_diff, UV).rgb + (1.0 - fac) * texture(cliff_diff, UV).rgb;
	NORMAL = fac * texture(sand_norm, UV).rgb + (1.0 - fac) * texture(cliff_norm, UV).rgb;
	ROUGHNESS = fac * texture(sand_rough, UV).r + (1.0 - fac) * texture(cliff_rough, UV).r;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
