shader_type spatial;

uniform sampler2D terrian_grass;
uniform sampler2D terrian_rock;
uniform float min_grass_height = -0.30;
uniform float max_rock_height = 1.50;
varying float vertex_y;
uniform vec2 uvscale = vec2(5);

void vertex() {
	vertex_y = VERTEX.y;
}

void fragment() {
	float vert_weight = vertex_y;
	vec3 grass = texture(terrian_grass,UV*uvscale).rgb;
	vec3 rock = texture(terrian_rock,UV*uvscale).rgb;
	
	float weight = smoothstep(min_grass_height,max_rock_height,vert_weight);
	vec3 final_color = mix(grass,rock,weight);
	ALBEDO = final_color.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
