shader_type spatial;

// --- Transvoxel transition support (from Zylann’s shader) ---
uniform int u_transition_mask;

float get_transvoxel_secondary_factor(int idata) {
	int transition_mask = u_transition_mask & 0xff;
	int cell_border_mask = (idata >> 0) & 63;
	int vertex_border_mask = (idata >> 8) & 63;
	int m = transition_mask & cell_border_mask;
	float t = float(m != 0);
	t *= float((vertex_border_mask & ~transition_mask) == 0);
	return t;
}

vec3 get_transvoxel_position(vec3 vertex_pos, vec4 fdata) {
	int idata = floatBitsToInt(fdata.a);
	float secondary_factor = get_transvoxel_secondary_factor(idata);
	vec3 secondary_position = fdata.xyz;
	vec3 pos = mix(vertex_pos, secondary_position, secondary_factor);
	int itransition = (idata >> 16) & 0xff;
	float transition_cull = float(itransition == 0 || (itransition & u_transition_mask) != 0);
	pos *= transition_cull;
	return pos;
}

// --- Texture blending system ---
uniform sampler2DArray u_texture_array;
uniform float uv_scale : hint_range(0.1, 10.0) = 0.5;

// Height-based control
uniform float grass_height = -0.2;
uniform float rock_height = 1.5;

// Painting weight influence
uniform float paint_strength = 1.0;

varying vec4 v_indices;
varying vec4 v_weights;
varying vec3 v_normal;
varying vec3 v_pos;

vec4 decode_8bit_vec4(float v) {
	uint i = floatBitsToUint(v);
	return vec4(
		float(i & uint(0xff)),
		float((i >> uint(8)) & uint(0xff)),
		float((i >> uint(16)) & uint(0xff)),
		float((i >> uint(24)) & uint(0xff)));
}

vec3 get_triplanar_blend(vec3 world_normal) {
	vec3 blending = abs(world_normal);
	blending = normalize(max(blending, vec3(0.00001)));
	float b = blending.x + blending.y + blending.z;
	return blending / vec3(b,b,b);
}

vec3 texture_array_triplanar(sampler2DArray tex, vec3 world_pos, vec3 blend, float i){
	vec3 xaxis = texture(tex, vec3(world_pos.yz, i)).rgb;
	vec3 yaxis = texture(tex, vec3(world_pos.xz, i)).rgb;
	vec3 zaxis = texture(tex, vec3(world_pos.xy, i)).rgb;
	return xaxis * blend.x + yaxis * blend.y + zaxis * blend.z;
}

void vertex() {
	VERTEX = get_transvoxel_position(VERTEX, CUSTOM0);
	v_indices = decode_8bit_vec4(CUSTOM1.x);
	v_weights = decode_8bit_vec4(CUSTOM1.y) / 255.0;
	v_pos = VERTEX;
	v_normal = NORMAL;
}

void fragment() {
	vec3 blending = get_triplanar_blend(v_normal);

	// --- Base height-based blend ---
	vec3 grass_col = texture_array_triplanar(u_texture_array, v_pos * uv_scale, blending, 0).rgb;
	vec3 rock_col  = texture_array_triplanar(u_texture_array, v_pos * uv_scale, blending, 1).rgb;

	float height_mix = smoothstep(grass_height, rock_height, v_pos.y);
	vec3 height_based = mix(grass_col, rock_col, height_mix);

	// --- Painted layer (uses weights from voxel buffer) ---
	vec3 paint0 = texture_array_triplanar(u_texture_array, v_pos * uv_scale, blending, v_indices.x).rgb;
	vec3 paint1 = texture_array_triplanar(u_texture_array, v_pos * uv_scale, blending, v_indices.y).rgb;
	vec3 paint2 = texture_array_triplanar(u_texture_array, v_pos * uv_scale, blending, v_indices.z).rgb;
	vec3 paint3 = texture_array_triplanar(u_texture_array, v_pos * uv_scale, blending, v_indices.w).rgb;

	vec4 weights = v_weights;
	weights /= (weights.x + weights.y + weights.z + weights.w + 0.00001);
	vec3 painted = paint0 * weights.r + paint1 * weights.g + paint2 * weights.b + paint3 * weights.a;

	// --- Combine ---
	vec3 final_col = mix(height_based, painted, paint_strength);
	ALBEDO = final_col;
}
