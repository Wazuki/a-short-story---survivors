shader_type canvas_item;

// Core distortion parameters
uniform float strength: hint_range(0.0, 0.1, 0.001) = 0.08; // How powerful the distortion is
uniform vec2 center = vec2(0.5, 0.5); // Wher ethe effect happens on screen (0.5 is the center)
uniform float radius: hint_range(0.0, 1.0, 0.001) = 0.25; // How big the effect is

// Visual effect parameters
uniform float aberration: hint_range(0.0, 1.0, 0.001) = 0.425; // Creates the cool rainbow effect at the edges
uniform float width: hint_range(0.0, 0.1, 0.0001) = 0.04; // How thick the distortion ring is
uniform float feather: hint_range(0.0, 1.0, 0.001) = 0.135; // How smooth the edges are

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap; // Gives access to what's shown on the screen

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	// 1. Basic Setup:
	vec2 screen_uv = SCREEN_UV; // Gives us our position

	// 2. Fix the stretching - makes the effect circular instead of oval
	float aspect_ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 aspect_corrected_uv = (screen_uv - vec2(0.0, 0.5)) / vec2(1.0, aspect_ratio) + vec2(0.0, 0.5);

	// 3. Find distance from center
	vec2 distance_from_center = aspect_corrected_uv - center;

	// 4. Create the ring shape
	float distance_length = length(distance_from_center);
	// Smoothstep to reduce hte harshness and make the edges smooth
	float outer_edge = smoothstep(radius - feather, radius, distance_length);
	float inner_edge = smoothstep(radius - width - feather, radius - width, distance_length);
	float distortion_mask = (1.0 - outer_edge) * inner_edge;

	// 5. Calculate how much to bend
	vec2 distortion_direction = normalize(distance_from_center);
	vec2 distortion_offset = distortion_direction * strength * distortion_mask;

	// 6. Apply the bend
	vec2 distorted_uv = aspect_corrected_uv - distortion_offset;

	// 7. Add rainbow effect
	vec2 color_seperation = distortion_offset * aberration * distortion_mask;

	// 8. Put it all together!
	vec2 final_uv = mix(screen_uv, distorted_uv, distortion_mask);

	// 9. Sample different colors
	vec4 red_channel = texture(SCREEN_TEXTURE, final_uv + color_seperation);
	vec4 base_color = texture(SCREEN_TEXTURE, final_uv);
	vec4 blue_channel = texture(SCREEN_TEXTURE, final_uv - color_seperation);

	// 10. Final color
	COLOR = vec4(
		red_channel.r,
		base_color.g,
		blue_channel.b,
		1.0
	);

}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
