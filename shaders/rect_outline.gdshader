shader_type canvas_item;

uniform float outline_thickness : hint_range(0.0, 0.5) = 0.05;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 fill_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec2 uv = UV;
    float dist_to_edge = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
    if (dist_to_edge < outline_thickness) {
        COLOR = outline_color;
    } 
	else {
        COLOR = fill_color;
    }
}
