shader_type canvas_item;

uniform sampler2D overlay : repeat_enable;
uniform sampler2D colour_overlay;
uniform vec2 scroll = vec2(0, -0.1);
uniform vec2 overlay_scroll = vec2(0, -0.2);

void fragment() {
	float texture_colour = texture(TEXTURE, UV + scroll * TIME).r;
	float overlay_colour = texture(overlay, UV + overlay_scroll * TIME).r;
	float energy = texture_colour * overlay_colour;
	COLOR = texture(colour_overlay, vec2(energy));
}
