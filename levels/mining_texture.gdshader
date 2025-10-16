shader_type spatial;

// This uniform is assigned internally by the voxel engine.
// Layout: 00000000 00000000 0000000 00xxyyzz
// Where:
// - xx are respectively -x and x transitions,
// - yy are respectively -y and y transitions,
// - zz are respectively -z and z transitions,
uniform int u_transition_mask;

float get_transvoxel_secondary_factor(int idata) {
    int transition_mask = u_transition_mask & 0xff;

    int cell_border_mask = (idata >> 0) & 63; // Which sides the cell is touching
    int vertex_border_mask = (idata >> 8) & 63; // Which sides the vertex is touching
    // If the vertex is near a side where there is a low-resolution neighbor,
    // move it to secondary position
    int m = transition_mask & cell_border_mask;
    float t = float(m != 0);
    // If the vertex lies on one or more sides, and at least one side has no low-resolution neighbor,
    // don't move the vertex.
    t *= float((vertex_border_mask & ~transition_mask) == 0);

    return t;
}

vec3 get_transvoxel_position(vec3 vertex_pos, vec4 fdata) {
    int idata = floatBitsToInt(fdata.a);

    // Move vertices to smooth transitions
    float secondary_factor = get_transvoxel_secondary_factor(idata);
    vec3 secondary_position = fdata.xyz;
    vec3 pos = mix(vertex_pos, secondary_position, secondary_factor);

    // If the mesh combines transitions and the vertex belongs to a transition,
    // when that transition isn't active we change the position of the vertices so
    // all triangles will be degenerate and won't be visible.
    // This is an alternative to rendering them separately,
    // which has less draw calls and less mesh resources to create in Godot.
    // Ideally I would tweak the index buffer like LOD does but Godot does not
    // expose anything to use it that way.
    int itransition = (idata >> 16) & 0xff; // Is the vertex on a transition mesh?
    float transition_cull = float(itransition == 0 || (itransition & u_transition_mask) != 0);
    pos *= transition_cull;

    return pos;
}

uniform sampler2DArray u_texture_array : source_color, filter_nearest;

varying vec4 v_indices;
varying vec4 v_weights;
varying vec3 v_normal;
varying vec3 v_pos;

vec4 decode_8bit_vec4(float v){
	uint i = floatBitsToUint(v);
	return vec4(
		float(i & uint(0xff)),
		float((i >> uint(8)) & uint(0xff)),
		float((i >> uint(16)) & uint(0xff)),
		float((i >> uint(24)) & uint(0xff)));
}

vec3 get_triplanar_blend(vec3 world_normal){
	vec3 blending = abs(world_normal);
	blending = normalize(max(blending, vec3(0.00001)));
	float b = blending.x + blending.y + blending.z;
	return blending / vec3(b,b,b);
}

vec4 texture_array_triplanar(sampler2DArray tex, vec3 world_pos, vec3 blend, float i){
	vec4 xaxis = texture(tex, vec3(world_pos.yz, i));
	vec4 yaxis = texture(tex, vec3(world_pos.xz, i));
	vec4 zaxis = texture(tex, vec3(world_pos.xy, i));
	return xaxis * blend.x + yaxis * blend.y + zaxis * blend.z;
}

void vertex() {
    VERTEX = get_transvoxel_position(VERTEX, CUSTOM0);

	v_indices = decode_8bit_vec4(CUSTOM1.x);
	v_weights = decode_8bit_vec4(CUSTOM1.x)/255.0;
	v_pos = VERTEX;
	v_normal = NORMAL;
}

void fragment(){
	float uv_scale = 0.5;
	vec3 blending = get_triplanar_blend(v_normal);
	vec3 col0 =  texture_array_triplanar(u_texture_array, v_pos * uv_scale, blending, v_indices.x).rgb;
	vec3 col1 =  texture_array_triplanar(u_texture_array, v_pos * uv_scale, blending, v_indices.y).rgb;
	vec3 col2 =  texture_array_triplanar(u_texture_array, v_pos * uv_scale, blending, v_indices.z).rgb;
	vec3 col3 =  texture_array_triplanar(u_texture_array, v_pos * uv_scale, blending, v_indices.w).rgb;

	vec4 weights = v_weights;
	weights /= (weights.x + weights.y + weights.z + weights.w + 0.00001);

	vec3 col =
		col0 * weights.r +
		col1 * weights.g +
		col2 * weights.b +
		col3 * weights.a;

	ALBEDO = col;
}