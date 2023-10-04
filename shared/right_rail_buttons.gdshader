shader_type canvas_item;
uniform float blue = 1.0;
uniform float red = 1.0;
uniform float green = 1.0;

// fragment() colors EVERY pixel
void fragment() {
	vec4 currentColor = texture(TEXTURE,UV).rgba;
	
	if (currentColor.r ==1.0) {
		currentColor.a = 0.0;
	}
	
	COLOR = currentColor;
	
	// https://docs.godotengine.org/en/stable/tutorials/shaders/your_first_shader/your_first_2d_shader.html
	// color is input variable and final output
	
	// assign a flat color
	//COLOR = vec4(0.4, 0.6, 0.9, 1.0);
	
	//COLOR = vec4(UV, 0.5, 1.0);
	
	//this shader will result in an all white rectangle
  	//COLOR.b = 1.0;
	
	//COLOR = texture(TEXTURE, UV); //read from texture
  	//COLOR.b = 1.0; //set blue channel to 1.0
	
	//COLOR = texture(TEXTURE, UV); //read from texture
  	//COLOR.b = blue;
	//COLOR.r = red;
	//COLOR.g = green;
	
	// INTERESTING:
	// blue and green set to 1 was wild...
}

// assigns WHERE each pixel should go
//void vertex() {
  //VERTEX += vec2(10.0, 0.0);
	
  // AMAZING
  // Animate Sprite2D moving in big circle around its location
  //VERTEX += vec2(cos(TIME)*100.0, sin(TIME)*100.0);
//}
