shader_type canvas_item;
instance uniform bool is_active = false;
instance uniform vec3 flash_color: source_color = vec3(0.8,0,0);
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 tex = texture(TEXTURE,UV);
	if (is_active){
		COLOR = vec4(flash_color,tex.a);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
