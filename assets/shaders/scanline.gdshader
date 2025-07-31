shader_type canvas_item;

uniform float speed = 1.0; // Adjust speed of the scanline
uniform vec4 scanline_color : source_color = vec4(0.0, 1.0, 1.0, 0.3); // Cyan glow

void fragment() {
    vec2 uv = UV;
    float line = sin((-uv.y + TIME * speed) * 20.0) * 0.5 + 0.5; // Adjust frequency with * 20.0
    vec4 original = texture(TEXTURE, uv);

    vec4 scanline = mix(original, scanline_color, line * 0.5); // Blend effect
    COLOR = scanline;
}