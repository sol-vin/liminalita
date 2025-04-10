shader_type spatial;
render_mode cull_disabled, fog_disabled, ambient_light_disabled;

/*
	Normal/Depth outline shader with improved stability.
	Inspired by Yui Kinomoto @arlez80, lukky_nl (YT), Robin Seibold (YT)
	Uses Sobel Edge detection on a normal and depth texture
	Original by William Li (LoudFlameLava)
	Modified to fix speckling, black artifacts, and angle-dependent issue
*/

uniform bool on = true;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest, repeat_disable;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest, repeat_disable;
//uniform vec3 albedo : source_color = vec3(1.0);

uniform float color_threshold = 0.001;
uniform vec3 outline_color: source_color = vec3(0.0, 0.0, 0.0);
uniform bool color_polygons = true;
uniform vec3 polygon_color: source_color = vec3(1.0, 1.0, 1.0);
uniform float outline_thickness = 0.5;
uniform float edge_blur = 1.0;
uniform bool exact_color_match = false;
uniform bool remove_isolated_pixels = true;
uniform int min_connected_edges = 3;
uniform float normal_texture_mix = 0.1;
uniform float isolated_normal_texture_mix = 0.1;



const mat3 gaussian = mat3(
    vec3(1.0, 2.0, 1.0),
    vec3(2.0, 4.0, 2.0),
    vec3(1.0, 2.0, 1.0)
) / 16.0;

const mat3 sobel_y = mat3(
    vec3(1.0, 0.0, -1.0),
    vec3(2.0, 0.0, -2.0),
    vec3(1.0, 0.0, -1.0)
);

const mat3 sobel_x = mat3(
    vec3(1.0, 2.0, 1.0),
    vec3(0.0, 0.0, 0.0),
    vec3(-1.0, -2.0, -1.0)
);

float color_difference(vec3 a, vec3 b) {
    if (exact_color_match) {
        vec3 diff = abs(a - b);
        float epsilon = 0.0001;
        //return (diff.r < epsilon && diff.g < epsilon && diff.b < epsilon) ? 0.0 : 1.0;
		return a == b ? 0.0 : 1.0;
    } else {
        vec3 weights = vec3(0.299, 0.587, 0.114);
        float luminance_diff = abs(dot(a, weights) - dot(b, weights));

        vec3 diff = abs(a - b);
        return sqrt(diff.r * diff.r * 0.299 + diff.g * diff.g * 0.587 + diff.b * diff.b * 0.114) + luminance_diff;
    }
}

vec3 blur_color(sampler2D normal_tex, sampler2D screen_tex, vec2 uv, vec2 pixel_size) {
    vec3 blurred = vec3(0.0);

    for(int i = -1; i <= 1; i++) {
        for(int j = -1; j <= 1; j++) {
            vec2 offset = vec2(float(i), float(j)) * pixel_size * outline_thickness;
            blurred += texture(screen_tex, uv + offset).rgb * gaussian[i+1][j+1];
        }
    }

    return mix(blurred, texture(normal_tex, uv).rgb, normal_texture_mix);
}

float edge_value_color(sampler2D normal_tex, sampler2D screen_tex, vec2 uv, vec2 pixel_size, mat3 sobel) {
    float output = 0.0;

    vec3 center = blur_color(normal_tex, screen_tex, uv, pixel_size);

    vec3 n = blur_color(normal_tex, screen_tex, uv + vec2(0.0, -pixel_size.y) * outline_thickness, pixel_size);
    vec3 s = blur_color(normal_tex, screen_tex, uv + vec2(0.0, pixel_size.y) * outline_thickness, pixel_size);
    vec3 e = blur_color(normal_tex, screen_tex, uv + vec2(pixel_size.x, 0.0) * outline_thickness, pixel_size);
    vec3 w = blur_color(normal_tex, screen_tex, uv + vec2(-pixel_size.x, 0.0) * outline_thickness, pixel_size);
    vec3 nw = blur_color(normal_tex, screen_tex, uv + vec2(-pixel_size.x, -pixel_size.y) * outline_thickness, pixel_size);
    vec3 ne = blur_color(normal_tex, screen_tex, uv + vec2(pixel_size.x, -pixel_size.y) * outline_thickness, pixel_size);
    vec3 sw = blur_color(normal_tex, screen_tex, uv + vec2(-pixel_size.x, pixel_size.y) * outline_thickness, pixel_size);
    vec3 se = blur_color(normal_tex, screen_tex, uv + vec2(pixel_size.x, pixel_size.y) * outline_thickness, pixel_size);

    float dN = color_difference(center, n);
    float dS = color_difference(center, s);
    float dE = color_difference(center, e);
    float dW = color_difference(center, w);
    float dNE = color_difference(center, ne);
    float dNW = color_difference(center, nw);
    float dSE = color_difference(center, se);
    float dSW = color_difference(center, sw);

    mat3 error_mat = mat3(
        vec3(dNW, dN, dNE),
        vec3(dW, 0.0, dE),
        vec3(dSW, dS, dSE)
    );

    output += dot(sobel[0], error_mat[0]);
    output += dot(sobel[1], error_mat[1]);
    output += dot(sobel[2], error_mat[2]);

    return smoothstep(0.0, edge_blur, abs(output));
}

int count_edge_neighbors(sampler2D normal_tex, sampler2D screen_tex, vec2 uv, vec2 pixel_size, float threshold) {
    vec3 center = mix(texture(normal_tex, uv).rgb, texture(screen_tex, uv).rgb, isolated_normal_texture_mix);
    int count = 0;

    for(int i = -1; i <= 1; i++) {
        for(int j = -1; j <= 1; j++) {
            if(i == 0 && j == 0) continue;

            vec2 offset = vec2(float(i), float(j)) * pixel_size;
            vec3 neighbor = mix(texture(normal_tex, uv + offset).rgb, texture(screen_tex, uv + offset).rgb, isolated_normal_texture_mix);

            if(color_difference(center, neighbor) > threshold) {
                count++;
            }
        }
    }

    return count;
}

void fragment() {
	if(on) {
	    vec2 pixel_size = vec2(1.0) / VIEWPORT_SIZE;
	    //vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);

	    float color_edge = edge_value_color(NORMAL_TEXTURE, SCREEN_TEXTURE, SCREEN_UV, pixel_size, sobel_x) +
	                       edge_value_color(NORMAL_TEXTURE, SCREEN_TEXTURE, SCREEN_UV, pixel_size, sobel_y);

	    float outline = color_edge > color_threshold ? 1.0 : 0.0;

	    if(remove_isolated_pixels && outline > 0.1) {
	        int edge_count = count_edge_neighbors(NORMAL_TEXTURE, SCREEN_TEXTURE, SCREEN_UV, pixel_size, color_threshold);
	        if(edge_count < min_connected_edges) {
	            outline = 0.0;
	        }
	    }


	    float outline_alpha = smoothstep(0.0, edge_blur, outline);
	    if (outline_alpha > 0.01) {
	        EMISSION = mix(polygon_color, outline_color, outline_alpha);
			ALBEDO = mix(polygon_color, outline_color, outline_alpha);
	    } else if (color_polygons) {
			EMISSION = polygon_color;
			ALBEDO = polygon_color;
	        //ALBEDO = mix(NORMAL, texture(SCREEN_TEXTURE, SCREEN_UV).rgb, 0.1);
		} else {
			ALPHA = 0.0;
	    }
	} else  {
		ALBEDO = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
		//ALBEDO = albedo;
	}
}
//
//void light() {
	//DIFFUSE_LIGHT = mix(DIFFUSE_LIGHT, LIGHT_COLOR, ATTENUATION * max(dot(LIGHT,NORMAL), 0.0));
//}
