shader_type canvas_item;

uniform vec3 replacement_color:source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 color_without_blue = COLOR.rgb * vec3(1,1,0); // .rgb is a swizzle
	float amount_red_and_green = length(color_without_blue);
	float red_and_green_mask = step(0.92, amount_red_and_green);


	vec3 retained_color = COLOR.rgb * red_and_green_mask;
	float blue_mask = (1.0 - red_and_green_mask) * COLOR.b;

	vec3 masked_replacement_color = replacement_color * blue_mask;
	vec3 final_color = retained_color + masked_replacement_color;
	COLOR.rgb = vec3(final_color); // Shorthand for creating a vec3 from one var
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
