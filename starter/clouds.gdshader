shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
// Provisional new cloud treatment. Not the unrecovered historical setup.
uniform vec4 cloud_color : source_color = vec4(0.89,0.94,1.0,0.65);
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453123);}
float noise(vec2 p){vec2 i=floor(p);vec2 f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void fragment(){vec2 p=UV*9.0+vec2(TIME*0.006,0.0);float n=noise(p)*0.55+noise(p*2.0)*0.28+noise(p*4.0)*0.13;ALBEDO=cloud_color.rgb;ALPHA=smoothstep(0.40,0.70,n)*cloud_color.a;}
