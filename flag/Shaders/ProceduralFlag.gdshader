// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

group_uniforms BaseLayer;
uniform int shape : hint_enum("Rectangle", "Point", "Swallowtail", "Triangular Pennant", "Tapering Pennant", "Swallowtail Pennant") = 0;
uniform vec2 ratio = vec2(1.0, 1.0);
uniform vec4 colour_base : source_color = vec4(1.0, 1.0, 1.0, 1.0);
group_uniforms;

group_uniforms Layer1;
uniform int shape_1 : hint_enum("None", "Horizontal Bars", "Vertical Bars", "Rings", "Boxes", "Diamonds", "Burst", "Checked", "Circle Ring", "Triangle Ring", "Square Ring", "Moon Ring", "Plus Ring", "Flower Ring", "Star Ring", "Shuriken Ring") = 0;
uniform int count_1 : hint_range(1, 20) = 3;
uniform vec2 scale_1 = vec2(1.0, 1.0);
uniform vec2 offset_1 = vec2(0.0, 0.0);
uniform float rotation_1 : hint_range(-180.0, 180.0) = 0;
group_uniforms Layer1.Colours;
uniform vec4 colour_1_01 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_02 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_03 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_04 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_05 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_06 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_07 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_08 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_09 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_10 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_11 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_12 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_13 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_14 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_15 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_16 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_17 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_18 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_19 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_1_20 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
group_uniforms;

group_uniforms Layer2;
uniform int shape_2 : hint_enum("None", "Horizontal Bars", "Vertical Bars", "Rings", "Boxes", "Diamonds", "Burst", "Checked", "Circle Ring", "Triangle Ring", "Square Ring", "Moon Ring", "Plus Ring", "Flower Ring", "Star Ring", "Shuriken Ring") = 0;
uniform int count_2 : hint_range(1, 20) = 3;
uniform vec2 scale_2 = vec2(1.0, 1.0);
uniform vec2 offset_2 = vec2(0.0, 0.0);
uniform float rotation_2 : hint_range(-180.0, 180.0) = 0;
group_uniforms Layer2.Colours;
uniform vec4 colour_2_01 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_02 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_03 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_04 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_05 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_06 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_07 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_08 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_09 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_10 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_11 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_12 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_13 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_14 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_15 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_16 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_17 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_18 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_19 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_2_20 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
group_uniforms;

group_uniforms Layer3;
uniform int shape_3 : hint_enum("None", "Horizontal Bars", "Vertical Bars", "Rings", "Boxes", "Diamonds", "Burst", "Checked", "Circle Ring", "Triangle Ring", "Square Ring", "Moon Ring", "Plus Ring", "Flower Ring", "Star Ring", "Shuriken Ring") = 0;
uniform int count_3 : hint_range(1, 20) = 3;
uniform vec2 scale_3 = vec2(1.0, 1.0);
uniform vec2 offset_3 = vec2(0.0, 0.0);
uniform float rotation_3 : hint_range(-180.0, 180.0) = 0;
group_uniforms Layer3.Colours;
uniform vec4 colour_3_01 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_02 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_03 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_04 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_05 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_06 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_07 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_08 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_09 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_10 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_11 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_12 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_13 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_14 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_15 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_16 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_17 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_18 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_19 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_3_20 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
group_uniforms;

group_uniforms Layer4;
uniform int shape_4 : hint_enum("None", "Horizontal Bars", "Vertical Bars", "Rings", "Boxes", "Diamonds", "Burst", "Checked", "Circle Ring", "Triangle Ring", "Square Ring", "Moon Ring", "Plus Ring", "Flower Ring", "Star Ring", "Shuriken Ring") = 0;
uniform int count_4 : hint_range(1, 20) = 3;
uniform vec2 scale_4 = vec2(1.0, 1.0);
uniform vec2 offset_4 = vec2(0.0, 0.0);
uniform float rotation_4 : hint_range(-180.0, 180.0) = 0;
group_uniforms Layer4.Colours;
uniform vec4 colour_4_01 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_02 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_03 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_04 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_05 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_06 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_07 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_08 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_09 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_10 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_11 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_12 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_13 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_14 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_15 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_16 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_17 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_18 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_19 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_4_20 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
group_uniforms;

group_uniforms Layer5;
uniform int shape_5 : hint_enum("None", "Horizontal Bars", "Vertical Bars", "Rings", "Boxes", "Diamonds", "Burst", "Checked", "Circle Ring", "Triangle Ring", "Square Ring", "Moon Ring", "Plus Ring", "Flower Ring", "Star Ring", "Shuriken Ring") = 0;
uniform int count_5 : hint_range(1, 20) = 3;
uniform vec2 scale_5 = vec2(1.0, 1.0);
uniform vec2 offset_5 = vec2(0.0, 0.0);
uniform float rotation_5 : hint_range(-180.0, 180.0) = 0;
group_uniforms Layer5.Colours;
uniform vec4 colour_5_01 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_02 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_03 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_04 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_05 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_06 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_07 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_08 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_09 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_10 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_11 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_12 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_13 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_14 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_15 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_16 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_17 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_18 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_19 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 colour_5_20 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
group_uniforms;

group_uniforms Image;
uniform bool use_image = false;
uniform sampler2D texture_image : source_color, filter_linear_mipmap;
group_uniforms;

group_uniforms Border;
uniform float left_border_width = 0.02;
uniform vec3 left_border_colour : source_color = vec3(1.0, 1.0, 1.0);
uniform float right_border_width = 0.02;
uniform vec3 right_border_colour : source_color = vec3(1.0, 1.0, 1.0);
uniform float top_border_width = 0.02;
uniform vec3 top_border_colour : source_color = vec3(1.0, 1.0, 1.0);
uniform float bottom_border_width = 0.02;
uniform vec3 bottom_border_colour : source_color = vec3(1.0, 1.0, 1.0);
group_uniforms;

group_uniforms NormalMap;
uniform bool woven = true;
uniform float weave_density : hint_range(10.0, 10000.0) = 500;
uniform float weave_depth : hint_range(0.0, 1.0) = 0.1;
uniform float edge : hint_range(0.0, 0.1) = 0.02;
uniform bool eyelets = true;
uniform float eyelet_inset = 0.01;
uniform float eyelet_radius = 0.008;
group_uniforms;

group_uniforms Wind;
uniform float wind_strength : hint_range(0.0, 10.0) = 2.0;
group_uniforms;

group_uniforms MasterUVs;
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
group_uniforms;

varying vec2 base_uv;
varying vec2 shaped_uv;

float x_truncate(float y)
{
	float retVal = 0.0;

	if (shape == 1)
	{
		retVal = abs(y - 0.5);
	}
	if (shape == 2)
	{
		retVal = 0.5 - abs(y - 0.5);
	}
	if (shape == 3)
	{
		retVal = 2.0 * ratio.y / ratio.x * abs(y - 0.5);
	}
	if (shape == 4)
	{
		if (y >= 1.0 / 3.0 && y <= 2.0 / 3.0)
		{
			retVal = 0.0;
		}
		else
		{
			retVal = 3.0 * (ratio.y / ratio.x) * abs(y - 0.5) - (ratio.y / ratio.x) * 0.5;
		}
	}
	if (shape == 5)
	{
		if (y >= 1.0 / 3.0 && y <= 2.0 / 3.0)
		{
			retVal = 0.5 - (3.0 * abs(y - 0.5));
		}
		else
		{
			retVal = 3.0 * (ratio.y / ratio.x) * abs(y - 0.5) - (ratio.y / ratio.x) * 0.5;
		}
	}

	return retVal;
}

vec4 bars_horizontal_albedo(int i, int count, vec4[20] colours, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);
	if (uv.x >= 0.0 && uv.x <= ratio.y / ratio.x && uv.y >= 0.0 && uv.y <= 1.0)
	{
		if (uv.y <= float(i) / float(count) && uv.y > float(i - 1) / float(count))
		{
			retVal = colours[i - 1];
		}
	}
	return retVal;
}

vec4 bars_vertical_albedo(int i, int count, vec4[20] colours, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);
	uv.x *= ratio.x / ratio.y;
	if (uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0)
	{
		if (uv.x <= float(i) / float(count) && uv.x > float(i - 1) / float(count))
		{
			retVal = colours[i - 1];
		}
	}
	return retVal;
}

vec4 rings_albedo(int i, int count, vec4[20] colours, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);

	uv -= vec2(ratio.y * 0.5 / ratio.x, 0.5);
	if (sqrt((uv.x * uv.x) + (uv.y * uv.y)) <= float(i) * 0.5 / float(count) && sqrt((uv.x * uv.x) + (uv.y * uv.y)) > float(i - 1) * 0.5 / float(count))
	{
		if (uv.x >= -1.0 && uv.x <= 1.0 && uv.y >= -1.0 && uv.y <= 1.0)
		{
			retVal = colours[i - 1];
		}
	}

	return retVal;
}

vec4 boxes_albedo(int i, int count, vec4[20] colours, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);

	uv -= vec2(ratio.y * 0.5 / ratio.x, 0.5);
	if ((abs(uv.x) <= float(i) * 0.5 / float(count) && abs(uv.y) <= float(i) * 0.5 / float(count)) && !(abs(uv.x) <= float(i - 1) * 0.5 / float(count) && abs(uv.y) <= float(i - 1) * 0.5 / float(count)))
	{
		retVal = colours[i - 1];
	}

	return retVal;
}

vec4 diamonds_albedo(int i, int count, vec4[20] colours, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);

	float inverseSqrt2 = 1.0 / sqrt(2.0);

	uv -= vec2(ratio.y * 0.5 / ratio.x, 0.5);
	uv = vec2((uv.x * inverseSqrt2) - (uv.y * inverseSqrt2), (uv.x * inverseSqrt2) + (uv.y * inverseSqrt2));
	uv *= sqrt(2.0);
	if ((abs(uv.x) <= float(i) * 0.5 / float(count) && abs(uv.y) <= float(i) * 0.5 / float(count)) && !(abs(uv.x) <= float(i - 1) * 0.5 / float(count) && abs(uv.y) <= float(i - 1) * 0.5 / float(count)))
	{
		retVal = colours[i - 1];
	}

	return retVal;
}

vec4 burst_albedo(int i, int count, vec4[20] colours, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);

	uv -= vec2(ratio.y * 0.5 / ratio.x, 0.5);
	if (sqrt((uv.x * uv.x) + (uv.y * uv.y)) <= 0.5 && sqrt((uv.x * uv.x) + (uv.y * uv.y)) > 0.0)
	{
		float theta = atan(uv.y, uv.x);
		theta += PI;
		if (theta >= 2.0 * PI * float(i - 1) / float(count) && theta < 2.0 * PI * float(i) / float(count))
		{
			retVal = colours[i - 1];
		}
	}

	return retVal;
}

vec4 checked_albedo(int i, int count, vec4[20] colours, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);
	uv.x *= ratio.x / ratio.y;
	uv.y *= ratio.x / ratio.y;

	int j = i;

	if (uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0)
	{
		if (uv.x <= float(i) / float(count) && uv.x > float(i - 1) / float(count))
		{
			j = j + int(floor(uv.y * float(count)));

			if (count % 2 == 0)
			{
				retVal = colours[(count + j - 1) % count];
			}
			else
			{
				j += 1;
				retVal = colours[(count + j - 1) % (count + 1)];
			}
		}
	}
	return retVal;
}

vec4 draw_circle(vec4 colour, float size, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);

	if (sqrt((uv.x * uv.x) + (uv.y * uv.y)) <= size  && sqrt((uv.x * uv.x) + (uv.y * uv.y)) > 0.0)
	{
		retVal = colour;
	}

	return retVal;
}

vec4 draw_triangle(vec4 colour, float size, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);

	size *= sin(2.0 * PI / 6.0);
	uv.y += size * (1.01 - sin(PI / 3.0));

	if (uv.x < size * 0.5 && uv.x > size * -0.5 && uv.y < size * (0.5 * sin(2.0 * PI / 6.0)) && uv.y > size * -(0.5 - 0.0))
	{
		if (uv.x < size * 0.5 && uv.x > size * 0.0)
		{
			if (uv.y >= (uv.x - (size * 0.25)) * 2.0 * sin(PI / 3.0))
			{
				retVal = colour;
			}
		}
		else if (uv.x > size * -0.5 && uv.x < size * 0.0)
		{
			if (uv.y >= -(uv.x + (size * 0.25)) * 2.0 * sin(PI / 3.0))
			{
				retVal = colour;
			}
		}
	}

	return retVal;
}

vec4 draw_square(vec4 colour, float size, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);

	if (uv.x < size * 0.5 && uv.x > size * -0.5 && uv.y < size * 0.5 && uv.y > size * -0.5)
	{
		retVal = colour;
	}

	return retVal;
}

vec4 draw_moon(vec4 colour, float size, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);

	float cutout = size * 0.7;
	float nudge = size / PI;

	if (sqrt((uv.x * uv.x) + (uv.y * uv.y)) <= size  && sqrt((uv.x * uv.x) + (uv.y * uv.y)) > 0.0)
	{
		vec2 uv_nudge = uv - vec2(nudge, 0.0);
		if (!(sqrt((uv_nudge.x * uv_nudge.x) + (uv_nudge.y * uv_nudge.y)) <= cutout && sqrt((uv_nudge.x * uv_nudge.x) + (uv_nudge.y * uv_nudge.y)) > 0.0))
		{
			if (uv.x >= -1.0 && uv.x <= 1.0 && uv.y >= -1.0 && uv.y <= 1.0)
			{
				retVal = colour;
			}
		}
	}

	return retVal;
}

vec4 draw_plus(vec4 colour, float size, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);

	if (uv.x < size * 0.5 && uv.x > size * -0.5 && uv.y < size * 0.5 && uv.y > size * -0.5)
	{
		if (uv.x < size * (1.0 / 6.0) && uv.x > size * -(1.0 / 6.0))
		{
			retVal = colour;
		}
		else if (uv.y < size * (1.0 / 6.0) && uv.y > size * -(1.0 / 6.0))
		{
			retVal = colour;
		}
	}

	return retVal;
}

vec4 draw_flower(vec4 colour, float size, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);

	uv = vec2(-uv.y, uv.x);

	float theta = atan(uv.y, uv.x);
	theta += PI;
	float h = sqrt((uv.x * uv.x) + (uv.y * uv.y));

	int points = 5;
	float fraction = 1.0 / (float(points) * 2.0);
	float reach_base = 0.1;
	float reach_add = 0.6;
	for (float j = 0.0; j <= 1.0; j += fraction * 2.0)
	{
		if (theta >= 2.0 * PI * j && theta < 2.0 * PI * (j + fraction))
		{
			if (h < size * (reach_base + reach_add * (theta - 2.0 * PI * j)))
			{
				retVal = colour;
			}
		}
		else if (theta >= 2.0 * PI * (j + fraction) && theta < 2.0 * PI * (j + fraction + fraction))
		{
			if (h < size * (reach_base + reach_add * (2.0 * PI * (j + fraction + fraction) - theta)))
			{
				retVal = colour;
			}
		}
	}

	return retVal;
}

vec4 draw_star(vec4 colour, float size, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);

	uv = vec2(-uv.y, uv.x);

	float theta = atan(uv.y, uv.x);
	theta += PI;
	float h = sqrt((uv.x * uv.x) + (uv.y * uv.y));

	int points = 5;
	float fraction = 1.0 / (float(points) * 2.0);
	float reach_base = 0.2;
	float reach_add = 0.6;
	for (float j = 0.0; j <= 1.0; j += fraction * 2.0)
	{
		if (theta >= 2.0 * PI * j && theta < 2.0 * PI * (j + fraction))
		{
			float angle = theta - 2.0 * PI * j;

			if (h < size * (reach_base + reach_add * angle * angle))
			{
				retVal = colour;
			}
		}
		else if (theta >= 2.0 * PI * (j + fraction) && theta < 2.0 * PI * (j + fraction + fraction))
		{
			float angle = (2.0 * PI * (j + fraction + fraction) - theta);

			if (h < size * (reach_base + reach_add * angle * angle))
			{
				retVal = colour;
			}
		}
	}

	return retVal;
}

vec4 draw_shuriken(vec4 colour, float size, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);

	uv = vec2(-uv.y, uv.x);

	float theta = atan(uv.y, uv.x);
	theta += PI;
	float h = sqrt((uv.x * uv.x) + (uv.y * uv.y));

	int points = 6;
	float fraction = 1.0 / (float(points) * 2.0);
	float reach_base = 0.2;
	float reach_add = 0.6;
	for (float j = 0.0; j <= 1.0; j += fraction * 2.0)
	{
		if (theta >= 2.0 * PI * j && theta < 2.0 * PI * (j + fraction))
		{
			float angle = theta - 2.0 * PI * j;

			if (h < size * (reach_base + reach_add * angle * angle))
			{
				retVal = colour;
			}
		}
	}

	return retVal;
}

float ring_icon_size(int count)
{
	float retVal = 1.0;
	if (count > 1)
	{
		retVal = (1.0 / float(count + 2));
	}
	return retVal;
}

vec2 ring_icon_uv(int count, int i)
{
	vec2 retVal = -vec2(ratio.y * 0.5 / ratio.x, 0.5);
	if (count > 1)
	{
		float theta = (0.5 * PI) + float(i) * 2.0 * PI / float(count);
		retVal += vec2(0.33 * cos(theta), 0.33 * sin(theta));
	}
	return retVal;
}

vec4 circlering_albedo(int i, int count, vec4[20] colours, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);

	if (count == 1)
	{
		retVal = draw_circle(colours[i - 1], 0.4 / float(count), uv + ring_icon_uv(count, i));
	}
	else
	{
		retVal = draw_circle(colours[i - 1], 0.34 / float(count), uv + ring_icon_uv(count, i));
	}

	return retVal;
}

vec4 trianglering_albedo(int i, int count, vec4[20] colours, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);
	if (count == 1)
	{
		retVal = draw_triangle(colours[i - 1], 0.8 / float(count), uv + ring_icon_uv(count, i));
	}
	else
	{
		retVal = draw_triangle(colours[i - 1], 0.68 / float(count), uv + ring_icon_uv(count, i));
	}
	return retVal;
}

vec4 squarering_albedo(int i, int count, vec4[20] colours, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);
	if (count == 1)
	{
		retVal = draw_square(colours[i - 1], 0.8 / float(count), uv + ring_icon_uv(count, i));
	}
	else
	{
		retVal = draw_square(colours[i - 1], 0.68 / float(count), uv + ring_icon_uv(count, i));
	}
	return retVal;
}

vec4 moonring_albedo(int i, int count, vec4[20] colours, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);

	if (count == 1)
	{
		retVal = draw_moon(colours[i - 1], 0.4 / float(count), uv + ring_icon_uv(count, i));
	}
	else
	{
		retVal = draw_moon(colours[i - 1], 0.26 / float(count), uv + ring_icon_uv(count, i));
	}

	return retVal;
}

vec4 plusring_albedo(int i, int count, vec4[20] colours, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);
	if (count == 1)
	{
		retVal = draw_plus(colours[i - 1], 0.8 / float(count), uv + ring_icon_uv(count, i));
	}
	else
	{
		retVal = draw_plus(colours[i - 1], 0.68 / float(count), uv + ring_icon_uv(count, i));
	}
	return retVal;
}

vec4 flowerring_albedo(int i, int count, vec4[20] colours, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);
	retVal = draw_flower(colours[i - 1], ring_icon_size(count), uv + ring_icon_uv(count, i));
	return retVal;
}

vec4 starring_albedo(int i, int count, vec4[20] colours, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);
	retVal = draw_star(colours[i - 1], ring_icon_size(count), uv + ring_icon_uv(count, i));
	return retVal;
}

vec4 shurikenring_albedo(int i, int count, vec4[20] colours, vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);
	retVal = draw_shuriken(colours[i - 1], ring_icon_size(count), uv + ring_icon_uv(count, i));
	return retVal;
}

vec4 get_albedo(int pattern, int count, vec4[20] colours, vec2 uv, vec2 scale, vec2 offset, float rotation)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);

	float aspect = ratio.y / ratio.x;

	mat2 rotation_matrix = mat2(vec2(cos(radians(-rotation)), sin(radians(-rotation))), vec2(-sin(radians(-rotation)), cos(radians(-rotation))));

	vec2 raw_uv = uv;
	vec2 updated_uv = raw_uv;
	updated_uv = rotation_matrix * (raw_uv - vec2(0.5 * aspect, 0.5));
	updated_uv += vec2(0.5 * aspect, 0.5);
	updated_uv -= rotation_matrix * vec2(offset.x * aspect, offset.y) * 0.5;
	updated_uv = vec2(updated_uv.x / scale.x, updated_uv.y / scale.y) - vec2(((1.0 - scale.x) * 0.5 * aspect) / scale.x, ((1.0 - scale.y) * 0.5) / scale.y);

	for (int i = count; i > 0; i--)
	{
		if (pattern == 1)
		{
			vec4 alb = bars_horizontal_albedo(i, count, colours, updated_uv);
			if (alb.a > 0.0)
			{
				retVal = alb;
			}
		}
		if (pattern == 2)
		{
			vec4 alb = bars_vertical_albedo(i, count, colours, updated_uv);
			if (alb.a > 0.0)
			{
				retVal = alb;
			}
		}
		if (pattern == 3)
		{
			vec4 alb = rings_albedo(i, count, colours, updated_uv);
			if (alb.a > 0.0)
			{
				retVal = alb;
			}
		}
		if (pattern == 4)
		{
			vec4 alb = boxes_albedo(i, count, colours, updated_uv);
			if (alb.a > 0.0)
			{
				retVal = alb;
			}
		}
		if (pattern == 5)
		{
			vec4 alb = diamonds_albedo(i, count, colours, updated_uv);
			if (alb.a > 0.0)
			{
				retVal = alb;
			}
		}
		if (pattern == 6)
		{
			vec4 alb = burst_albedo(i, count, colours, updated_uv);
			if (alb.a > 0.0)
			{
				retVal = alb;
			}
		}
		if (pattern == 7)
		{
			vec4 alb = checked_albedo(i, count, colours, updated_uv);
			if (alb.a > 0.0)
			{
				retVal = alb;
			}
		}
		if (pattern == 8)
		{
			vec4 alb = circlering_albedo(i, count, colours, updated_uv);
			if (alb.a > 0.0)
			{
				retVal = alb;
			}
		}
		if (pattern == 9)
		{
			vec4 alb = trianglering_albedo(i, count, colours, updated_uv);
			if (alb.a > 0.0)
			{
				retVal = alb;
			}
		}
		if (pattern == 10)
		{
			vec4 alb = squarering_albedo(i, count, colours, updated_uv);
			if (alb.a > 0.0)
			{
				retVal = alb;
			}
		}
		if (pattern == 11)
		{
			vec4 alb = moonring_albedo(i, count, colours, updated_uv);
			if (alb.a > 0.0)
			{
				retVal = alb;
			}
		}
		if (pattern == 12)
		{
			vec4 alb = plusring_albedo(i, count, colours, updated_uv);
			if (alb.a > 0.0)
			{
				retVal = alb;
			}
		}
		if (pattern == 13)
		{
			vec4 alb = flowerring_albedo(i, count, colours, updated_uv);
			if (alb.a > 0.0)
			{
				retVal = alb;
			}
		}
		if (pattern == 14)
		{
			vec4 alb = starring_albedo(i, count, colours, updated_uv);
			if (alb.a > 0.0)
			{
				retVal = alb;
			}
		}
		if (pattern == 15)
		{
			vec4 alb = shurikenring_albedo(i, count, colours, updated_uv);
			if (alb.a > 0.0)
			{
				retVal = alb;
			}
		}
	}
	return retVal;
}

vec4 draw_border(vec2 uv)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);

	if (uv.y < top_border_width)
	{
		retVal = vec4(top_border_colour, 1.0);
	}
	if (uv.y > 1.0 - bottom_border_width)
	{
		retVal = vec4(bottom_border_colour, 1.0);
	}
	if (uv.x < left_border_width)
	{
		retVal = vec4(left_border_colour, 1.0);
	}
	if (uv.x > (ratio.y / ratio.x) - x_truncate(uv.y) - right_border_width)
	{
		retVal = vec4(right_border_colour, 1.0);
	}

	return retVal;
}

vec3 apply_texture(vec2 uv)
{
	vec3 retVal = vec3(0.5, 0.5, 1.0);
	if (woven)
	{
		if (uv.x > (ratio.y / ratio.x) - x_truncate(uv.y) - edge)
		{
			float y = fract(uv.y * weave_density * 10.0) * 2.0;
			retVal = vec3(0.5, 1.0 - y, sqrt(1.0 - (y * y)));
		}
		else if (uv.x < edge)
		{
			float y = fract(uv.y * weave_density * 10.0) * 2.0;
			retVal = vec3(0.5, 1.0 - y, sqrt(1.0 - (y * y)));
		}
		else if (uv.y < edge)
		{
			float x = fract(uv.x * weave_density * 10.0) * 2.0;
			retVal = vec3(x, 0.5, sqrt(1.0 - (x * x)));
		}
		else if (uv.y > 1.0 - edge)
		{
			float x = fract(uv.x * weave_density * 10.0) * 2.0;
			retVal = vec3(x, 0.5, sqrt(1.0 - (x * x)));
		}
		else
		{
			if (fract(uv.x * weave_density) < 0.5)
			{
				if (fract(uv.y * weave_density) < 0.5)
				{
					float y = fract(uv.y * weave_density) * 2.0;
					retVal = vec3(0.5, 1.0 - y, sqrt(1.0 - (y * y)));
				}
				else
				{
					float x = fract(uv.x * weave_density) * 2.0;
					retVal = vec3(x, 0.5, sqrt(1.0 - (x * x)));
				}
			}
			else
			{
				if (fract(uv.y * weave_density) < 0.5)
				{
					float x = (fract(uv.x * weave_density) - 0.5) * 2.0;
					retVal = vec3(x, 0.5, sqrt(1.0 - (x * x)));
				}
				else
				{
					float y = (fract(uv.y * weave_density) - 0.5) * 2.0;
					retVal = vec3(0.5, 1.0 - y, sqrt(1.0 - (y * y)));
				}
			}
		}
	}

	return retVal;
}

vec3 apply_eyelets(vec2 uv)
{
	vec3 retVal = vec3(-1.0, -1.0, -1.0);
	if (eyelets)
	{
		float inset_x = eyelet_inset;

		if (uv.x < inset_x * 2.0)
		{
			float inset_y1 = eyelet_inset;
			float inset_y2 = 1.0 - eyelet_inset;
			float radius = eyelet_radius;

			vec2 uv_eyelet1 = uv - vec2(inset_x, inset_y1);
			vec2 uv_eyelet2 = uv - vec2(inset_x, inset_y2);

			float eyelet_dist1 = sqrt((uv_eyelet1.x * uv_eyelet1.x) + (uv_eyelet1.y * uv_eyelet1.y));
			float eyelet_dist2 = sqrt((uv_eyelet2.x * uv_eyelet2.x) + (uv_eyelet2.y * uv_eyelet2.y));

			float eyelet_dist = eyelet_dist1;
			vec2 uv_eyelet = uv_eyelet1;
			if (eyelet_dist2 < eyelet_dist1)
			{
				eyelet_dist = eyelet_dist2;
				uv_eyelet = uv_eyelet2;
			}

			if (eyelet_dist < radius * 0.5)
			{
				retVal = vec3(0.0);
			}
			else if (eyelet_dist < radius * 0.75)
			{
				retVal = vec3(uv_eyelet * 100.0, 0.5);
			}
			else if (eyelet_dist < radius)
			{
				retVal = vec3(-uv_eyelet * 100.0, 0.5);
			}
		}
	}

	return retVal;
}

vec4 apply_image(vec2 uv, bool apply_image, sampler2D image)
{
	vec4 retVal = vec4(1.0, 1.0, 1.0, 0.0);

	if (apply_image)
	{
		retVal = texture(image, uv);
	}

	return retVal;
}

void vertex()
{
	UV = UV * uv1_scale.xy + uv1_offset.xy;

	VERTEX.y += (wind_strength * 0.1) * sin((VERTEX.x) + 1.0) * sin((TIME + (length(NODE_POSITION_WORLD)) + (VERTEX.z * 0.5)) * wind_strength * 0.5);

	float z_offset_strength = wind_strength * 0.5;
	VERTEX.z += (z_offset_strength * 0.1) * sin((VERTEX.x) + 1.0) * sin((TIME + (length(NODE_POSITION_WORLD)) + (VERTEX.z * 0.5)) * z_offset_strength * 0.5);

	base_uv = UV;
	shaped_uv = base_uv * (ratio.y / ratio.x);
}

void fragment()
{
	if (shaped_uv.y <= 1.0 && !(shaped_uv.x > (ratio.y / ratio.x) - x_truncate(shaped_uv.y)))
	{
		vec4 colours_1[20] = vec4[20](colour_1_01, colour_1_02, colour_1_03, colour_1_04, colour_1_05, colour_1_06, colour_1_07, colour_1_08, colour_1_09, colour_1_10, colour_1_11, colour_1_12, colour_1_13, colour_1_14, colour_1_15, colour_1_16, colour_1_17, colour_1_18, colour_1_19, colour_1_20);
		vec4 colours_2[20] = vec4[20](colour_2_01, colour_2_02, colour_2_03, colour_2_04, colour_2_05, colour_2_06, colour_2_07, colour_2_08, colour_2_09, colour_2_10, colour_2_11, colour_2_12, colour_2_13, colour_2_14, colour_2_15, colour_2_16, colour_2_17, colour_2_18, colour_2_19, colour_2_20);
		vec4 colours_3[20] = vec4[20](colour_3_01, colour_3_02, colour_3_03, colour_3_04, colour_3_05, colour_3_06, colour_3_07, colour_3_08, colour_3_09, colour_3_10, colour_3_11, colour_3_12, colour_3_13, colour_3_14, colour_3_15, colour_3_16, colour_3_17, colour_3_18, colour_3_19, colour_3_20);
		vec4 colours_4[20] = vec4[20](colour_4_01, colour_4_02, colour_4_03, colour_4_04, colour_4_05, colour_4_06, colour_4_07, colour_4_08, colour_4_09, colour_4_10, colour_4_11, colour_4_12, colour_4_13, colour_4_14, colour_4_15, colour_4_16, colour_4_17, colour_4_18, colour_4_19, colour_4_20);
		vec4 colours_5[20] = vec4[20](colour_5_01, colour_5_02, colour_5_03, colour_5_04, colour_5_05, colour_5_06, colour_5_07, colour_5_08, colour_5_09, colour_5_10, colour_5_11, colour_5_12, colour_5_13, colour_5_14, colour_5_15, colour_5_16, colour_5_17, colour_5_18, colour_5_19, colour_5_20);

		// BASE LAYER
		ALBEDO = colour_base.rgb;

		bool written = false;

		// BORDER
		if (!written)
		{
			vec4 border = draw_border(shaped_uv);
			if (border.a > 0.0)
			{
				ALBEDO = border.rgb;
				written = true;
			}
		}

		// LAYER 5
		if (!written)
		{
			vec4 albedo_5 = get_albedo(shape_5, count_5, colours_5, shaped_uv, scale_5, offset_5, rotation_5);
			if (albedo_5.a > 0.0)
			{
				ALBEDO = (ALBEDO * (1.0 - albedo_5.a)) + (albedo_5.rgb * albedo_5.a);
				written = true;
			}
		}

		// LAYER 4
		if (!written)
		{
			vec4 albedo_4 = get_albedo(shape_4, count_4, colours_4, shaped_uv, scale_4, offset_4, rotation_4);
			if (albedo_4.a > 0.0)
			{
				ALBEDO = (ALBEDO * (1.0 - albedo_4.a)) + (albedo_4.rgb * albedo_4.a);
				written = true;
			}
		}

		// LAYER 3
		if (!written)
		{
			vec4 albedo_3 = get_albedo(shape_3, count_3, colours_3, shaped_uv, scale_3, offset_3, rotation_3);
			if (albedo_3.a > 0.0)
			{
				ALBEDO = (ALBEDO * (1.0 - albedo_3.a)) + (albedo_3.rgb * albedo_3.a);
				written = true;
			}
		}

		// LAYER 2
		if (!written)
		{
			vec4 albedo_2 = get_albedo(shape_2, count_2, colours_2, shaped_uv, scale_2, offset_2, rotation_2);
			if (albedo_2.a > 0.0)
			{
				ALBEDO = (ALBEDO * (1.0 - albedo_2.a)) + (albedo_2.rgb * albedo_2.a);
				written = true;
			}
		}

		// LAYER 1
		if (!written)
		{
			vec4 albedo_1 = get_albedo(shape_1, count_1, colours_1, shaped_uv, scale_1, offset_1, rotation_1);
			if (albedo_1.a > 0.0)
			{
				ALBEDO = (ALBEDO * (1.0 - albedo_1.a)) + (albedo_1.rgb * albedo_1.a);
				written = true;
			}
		}

		// IMAGE
		vec4 albedo_tex = apply_image(base_uv, use_image, texture_image);
		ALBEDO = (albedo_tex.rgb * albedo_tex.a) + (ALBEDO * (1.0 - albedo_tex.a));

		NORMAL_MAP = apply_texture(shaped_uv);
		NORMAL_MAP_DEPTH = weave_depth;
		vec3 n = apply_eyelets(shaped_uv);
		if (n.z > 0.0)
		{
			NORMAL_MAP = n;
			NORMAL_MAP_DEPTH = 1.0;
			METALLIC = 0.0;
			SPECULAR = 0.5;
			ALBEDO = vec3(0.5);
		}
		else if (length(n) == 0.0)
		{
			ALPHA = 0.0;
		}
		else
		{
			METALLIC = 0.0;
			SPECULAR = 0.0;
			ROUGHNESS = 1.0;
		}

	}
	else
	{
		ALPHA = 0.0;
	}
}