shader_type canvas_item;

uniform float time : hint_range(0, 1.0) = 0.0; // Animation progress
uniform float intensity : hint_range(0, 1) = 1.0; // Scrambling intensity
uniform vec2 random_shift = vec2(0.1, 0.1); // Random shift range

void fragment() {
    // Base texture coordinates
    vec2 uv = UV;

    // Generate random displacement
    float scramble = fract(sin(dot(uv.xy + time, vec2(12.9898, 78.233))) * 43758.5453);

    // Apply scrambling effect based on intensity
    if (scramble < intensity) {
        uv.x += random_shift.x * (fract(sin(uv.y * 100.0 + time) * 43758.5453) - 0.5);
        uv.y += random_shift.y * (fract(sin(uv.x * 100.0 + time) * 43758.5453) - 0.5);
    }

    // Output the texture with scrambled UV
    COLOR = texture(TEXTURE, uv);
}