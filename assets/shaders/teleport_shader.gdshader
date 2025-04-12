shader_type canvas_item;

//uniform int sprite_sheet_columns: hint_range(1,22) = 22;
//uniform int sprite_sheet_rows: hint_range(1, 12) = 12;
//uniform vec2 sprite_sheet_size = vec2(768, 1408);
uniform vec2 frame_size = vec2(64, 64);

uniform float progress : hint_range(0.0, 1.0);
uniform float noise_density = 60;
uniform float beam_size : hint_range(0.01, 0.15);
uniform vec4 color : source_color = vec4(0.0, 1.02, 1.2, 1.0);

// We are generating our own noise here. You could experiment with the 
// built in SimplexNoise or your own noise texture for other effects.
vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) * 0.5 + 0.5;
}

void fragment()
{
	vec2 sprite_sheet_size = vec2(textureSize(TEXTURE, 0)); // Grab the pixel size of the whole spritesheet.
	vec4 tex = texture(TEXTURE, UV); // Grab the texture at this point in time
	vec2 current_point = sprite_sheet_size * UV; // Translate the normalized UV (0-1) to the actual pixel coords on the spritesheet.
	float row = floor(current_point.y / frame_size.y); // Retrieve the spritesheet row based on the current point divided by the frame size
	float column = floor(current_point.x / frame_size.x); // Same for column
	vec2 max_point = (frame_size * vec2(column, row)) + frame_size; // Finds the *bottom-right corner* of the current frame.
	vec2 new_uv = 1.0 - (max_point - current_point) / frame_size; // Normalize the UV between the current point and the bottom right (1.0).
	
	float noise = noise(new_uv * noise_density) * new_uv.y;
	
	float d1 = step(progress, noise);
	float d2 = step(progress - beam_size, noise);
	
	vec3 beam = vec3(d2 - d1) * color.rgb;
	
	tex.rgb += beam;
	tex.a *= d2;
	
	COLOR = tex;

}