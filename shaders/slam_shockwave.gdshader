shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec2 center;
uniform float force;
uniform float size;
uniform float thickness;
uniform float offset;

void fragment()
{
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 scaledUV = (SCREEN_UV - vec2(0.5, 0.0)) / vec2(ratio, 1.0) + vec2(0.5, 0.0); // Scale according to the aspect ratio, offsetting back to center
	float mask = (1.0 - smoothstep(size - 0.1, size,length(scaledUV - center))) * smoothstep(size - thickness - 0.1, size - thickness,length(scaledUV - center)); // Subtracting inverts mask after stepping through the scaled UV iwth smoothstep to feather it.

	vec2 display = normalize(scaledUV - center) * force * mask; // Returns the direction from the center coord multiplied by the mask
	// COLOR = vec4(SCREEN_UV - disp, 0.0, 1.0); // Maps the color to the UV, essentially creating a fixed gradient
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - display);
	
	// TODO - implement chromatic effect by offsetting r and b
	//COLOR.r = texture(SCREEN_TEXTURE,vec2(SCREEN_UV.x + offset, SCREEN_UV.y) - display).r;
	//COLOR.g = texture(SCREEN_TEXTURE,SCREEN_UV - display).g;
	//COLOR.b = texture(SCREEN_TEXTURE,vec2(SCREEN_UV.x - offset, SCREEN_UV.y) - display).b;
	
	// COLOR = texture(TEXTURE, UV); // Displays the original texture without any modification
	// COLOR = texture(TEXTURE, UV - vec2(10.5, 0.0)); // Displays the original texture without any modification
	//COLOR.rgb = vec3(mask);

}