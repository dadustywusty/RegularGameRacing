shader_type canvas_item;

uniform vec3 deep_purple  = vec3(0.18, 0.03, 0.14);
uniform vec3 aubergine    = vec3(0.46, 0.16, 0.32);
uniform vec3 orange_glow  = vec3(0.91, 0.33, 0.12);

void fragment() {
    float gradient = (UV.x + UV.y) * 0.5;
    float noise = sin(UV.x * 3.0 - TIME * 0.5) * cos(UV.y * 2.0 + TIME * 0.3);

    vec3 color_mix  = mix(deep_purple, aubergine, gradient);
    vec3 final_color = mix(color_mix, orange_glow, noise * 0.3);

    COLOR = vec4(final_color, 1.0);
}