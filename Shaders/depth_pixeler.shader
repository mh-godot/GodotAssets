shader_type spatial;
render_mode unshaded, depth_test_disable, cull_back, depth_draw_never;

uniform float resolution = 128.0;
uniform float blur = 0.5;

bool clip(vec3 v,float d){
	return v.x < d || v.y < d || v.z < d;
}

float nr(float x){
	return sign(x) * round(abs(x));
}
vec2 nrv2(vec2 x){
	return sign(x) * round(abs(x));
}
vec3 nrv3(vec3 x){
	return sign(x) * round(abs(x));
}

void fragment(){
	
	mat4 CAMERA_MATRIX = inverse(INV_CAMERA_MATRIX);
	
	vec2 pixel = vec2(resolution*VIEWPORT_SIZE.x/VIEWPORT_SIZE.y,resolution);
	vec2 pixel_screen = nrv2((SCREEN_UV*2.0-1.0)*pixel)/pixel*0.5+0.5;
	
	float depth = texture(DEPTH_TEXTURE, pixel_screen).r;
	vec4 view_pos = INV_PROJECTION_MATRIX * vec4((pixel_screen*2.0-1.0),(depth*2.0-1.0),1.0);
	view_pos.xyz/=view_pos.w;
	
	
	vec4 world_pos = CAMERA_MATRIX * vec4(view_pos.xyz,1.0);
	world_pos.xyz/=world_pos.w;
	
	//world_pos.xyz = nrv3(world_pos.xyz * resolution)/resolution;
	
	vec4 obj_pos = inverse(WORLD_MATRIX) * vec4(world_pos.xyz,1.0);
	obj_pos.xyz/=obj_pos.w;
	
	
	
	vec4 screen_color = textureLod(SCREEN_TEXTURE,pixel_screen,blur);
	
	ALBEDO = screen_color.rgb;
	
	if((clip(1.0-obj_pos.xyz,0.0) || clip(1.0+obj_pos.xyz,0.0))){
		discard;
	}
}