shader_type canvas_item;

uniform vec2 Direction = vec2(1.0f, 0.0);
uniform float Speed = 0.03;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(TEXTURE, UV + (Direction * TIME * Speed));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
