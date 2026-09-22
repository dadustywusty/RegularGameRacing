shader_type canvas_item;

uniform sampler2D noise : repeat_enable;
uniform float fps = 15.0;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	float aspect_ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 corrected_uv = SCREEN_UV;
	corrected_uv.x *= aspect_ratio;
	
	float time_step = floor(TIME * fps);
	vec2 offset = vec2(time_step * 0.17, time_step * 0.31);
	
	vec4 color = texture(noise, corrected_uv + offset);
	COLOR = color * COLOR;
}
