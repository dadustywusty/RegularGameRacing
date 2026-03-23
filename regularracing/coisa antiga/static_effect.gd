extends ColorRect

func _ready():
	visible = false
	material = ShaderMaterial.new()
	var shader = Shader.new()
	shader.code = """
shader_type canvas_item;

uniform float noise_amount : hint_range(0.0, 1.0) = 0.8;

float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	float noise = random(uv + TIME * 50.0);
	vec3 static_color = vec3(noise) * noise_amount;
	COLOR = vec4(static_color, 1.0);
}
"""
	material.shader = shader

func show_effect():
	visible = true

func hide_effect():
	visible = false
