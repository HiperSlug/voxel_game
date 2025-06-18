shader_type canvas_item;

uniform float pixel_size = 10.0; // size of each pixel block in screen pixels
uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
    vec2 uv = SCREEN_UV * vec2(textureSize(screen_texture, 0)); // convert to screen pixel coords

    // Snap uv coords to nearest pixel block
    uv = floor(uv / pixel_size) * pixel_size;

    // Convert back to normalized UV coords
    uv /= vec2(textureSize(screen_texture, 0));

    // Sample the screen texture at snapped coordinates
    vec4 color = texture(screen_texture, uv);

    COLOR = color;
}
