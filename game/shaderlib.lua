
local shadercommon = [[

]]

shaderepi_effect = [[
		extern number time;
		vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
		{
			return vec4((1.0+sin(time))/2.0, abs(cos(time*3)), abs(sin(time*2)), 1.0);
			//vec4 texcolor = Texel(texture, texture_coords);
			//return texcolor * color * vec4( 0.8, 0.8, 0.8, 1);
		}
	]]

shadercombo = [[
		extern number time;
		extern number factor;
		extern number angle;
		vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
		{
			vec3 epi_effect = vec3((1.0+sin(time))/2.0, abs(cos(time*3)), abs(sin(time*2)));
			float factime = 0.01;
			number pixelfact = 10;
			number xnew = screen_coords.x * cos(angle) + screen_coords.y * sin(angle);
			number ynew = -screen_coords.x * sin(angle) + screen_coords.y * cos(angle);
			number p = (floor(xnew/pixelfact + 0.5)*pixelfact) / 100;
			number q = (floor(ynew/pixelfact + 0.5)*pixelfact);
			vec3 psych_effect = vec3(1.5+sin(p+time*factime),2+sin(p+time*factime),1+sin(p+time*factime)) * vec3(q+150)/600 * vec3((1.0+sin(time*factime))/2.0, abs(cos(time*factime*3)), abs(sin(factime*time*2)));
			//return factor * psych_effect + (1-factor) * psych_effect;
			return vec4( epi_effect * factor + psych_effect * (1-factor), 1 );

			//vec4 texcolor = Texel(texture, texture_coords);
			//return texcolor * color * vec4( 0.8, 0.8, 0.8, 1);
		}
	]]



shaderwave = [[
	extern number time;
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
	{
		number p = (screen_coords.x) / 100;
		return vec4(1.5+sin(p+time),2+sin(p+time),1+sin(p+time),1.0) * vec4(screen_coords.y+150)/600 * vec4((1.0+sin(time))/2.0, abs(cos(time*3)), abs(sin(time*2)), 1.0);
		//vec4 texcolor = Texel(texture, texture_coords);
		//return texcolor * color * vec4( 0.8, 0.8, 0.8, 1);
	}
]]

shaderwave2 = [[
	// helper function, please ignore
	number _hue(number s, number t, number h)
	{
	h = mod(h, 1.);
	number six_h = 6.0 * h;
	if (six_h < 1.) return (t-s) * six_h + s;
	if (six_h < 3.) return t;
	if (six_h < 4.) return (t-s) * (4.-six_h) + s;
	return s;
	}

	// input: vec4(h,s,l,a), with h,s,l,a = 0..1
	// output: vec4(r,g,b,a), with r,g,b,a = 0..1
	vec4 hsl_to_rgb(vec4 c)
	{
	if (c.y == 0)
		return vec4(vec3(c.z), c.a);

	number t = (c.z < .5) ? c.y*c.z + c.z : -c.y*c.z + (c.y+c.z);
	number s = 2.0 * c.z - t;
	return vec4(_hue(s,t,c.x + 1./3.), _hue(s,t,c.x), _hue(s,t,c.x - 1./3.), c.w);
	}

	float distance( number x1, number y1, number x2, number y2 )
	{
		return sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2));
	}

	extern number time;
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
	{
		number px = (screen_coords.x);
		number py = (screen_coords.y);
		//number col = 0.5 + (0.5 * sin( (px*py) / 8.0)); 
		//number col = 0.5 +
		//	(0.5 * sin( time + (px) / 16.0 )) +
		//	(0.5 * sin( time + (py) / 16.0 )); 
		number value = sin( distance( px + time, py, 128, 128 ) / 8.0 )
		             + sin( distance( px,       py, 64, 64 ) / 8.0 )
		             + sin( distance( px, py+time/7, 192, 64 ) / 7.0 )
		             + sin( distance( px, py, 192, 100 ) / 8.0 ); 
		number col = (32/255) * (4/255 + value);
		number fact = 0.2;
		return vec4(
			(4 + sin( distance( px + time, py, 128, 128 ) / 8.0 )
		             + sin( distance( px,       py, 64, 64 ) / 8.0 )
		             + sin( distance( px, py+time/7, 192, 64 ) / 7.0 )
		             + sin( distance( px, py, 192, 100 ) / 8.0 ))/255
		             ,(4+ 2 * sin( distance( px + time, py, 128, 128 ) / 8.0 )
		             + sin( distance( px,       py, 64, 64 ) / 8.0 )
		             + sin( distance( px, py+time/7, 192, 64 ) / 7.0 )
		             + sin( distance( px, py, 192, 100 ) / 8.0 ))/255
		    ,1  -(4+ sin( distance( px + time, py, 128, 128 ) / 8.0 )
		             + sin( distance( px,       py, 64, 64 ) / 8.0 )
		             + sin( distance( px, py+time/7, 192, 64 ) / 7.0 )
		             + sin( distance( px, py, 192, 100 ) / 8.0 )
		             ,1)/255,1);




	}
]]


weirdwaveee = [[
	// helper function, please ignore
	number _hue(number s, number t, number h)
	{
	h = mod(h, 1.);
	number six_h = 6.0 * h;
	if (six_h < 1.) return (t-s) * six_h + s;
	if (six_h < 3.) return t;
	if (six_h < 4.) return (t-s) * (4.-six_h) + s;
	return s;
	}

	// input: vec4(h,s,l,a), with h,s,l,a = 0..1
	// output: vec4(r,g,b,a), with r,g,b,a = 0..1
	vec4 hsl_to_rgb(vec4 c)
	{
	if (c.y == 0)
		return vec4(vec3(c.z), c.a);

	number t = (c.z < .5) ? c.y*c.z + c.z : -c.y*c.z + (c.y+c.z);
	number s = 2.0 * c.z - t;
	return vec4(_hue(s,t,c.x + 1./3.), _hue(s,t,c.x), _hue(s,t,c.x - 1./3.), c.w);
	}

	float distance( number x1, number y1, number x2, number y2 )
	{
		return sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2));
	}

	extern number time;
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
	{
		number px = (screen_coords.x-400);
		number py = (screen_coords.y-300);
		//number col = 0.5 + (0.5 * sin( (px*py) / 8.0)); 
		//number col = 0.5 +
		//	(0.5 * sin( time + (px) / 16.0 )) +
		//	(0.5 * sin( time + (py) / 16.0 )); 
		number value = sin( distance( px + time, py, 0.5, 0.5 ) / 8.0 )
		             + sin( distance( px,       py, 0.25, 0.25 ) / 8.0 )
		             + sin( distance( px, py+time, 0.66, 0.25 ) / 7.0 )
		             + sin( distance( px, py, 0.66, 0.40 ) / 8.0 ); 
		number col = (32/255) * (4/255 + value);
		return vec4(
			sin( distance( px + time, py, 0.5, 0.5 ) / 8.0 )
		             + sin( distance( px,       py, 0.25, 0.25 ) / 8.0 )
		             + sin( distance( px, py+time, 0.66, 0.25 ) / 7.0 )
		             + sin( distance( px, py, 0.66, 0.40 ) / 8.0 )
			,
			2 * sin( distance( px + time, py, 0.5, 0.5 ) / 8.0 )
		             + sin( distance( px,       py, 0.25, 0.25 ) / 8.0 )
		             + sin( distance( px, py+time, 0.66, 0.25 ) / 7.0 )
		             + sin( distance( px, py, 0.66, 0.40 ) / 8.0 )
		    ,
			1 - sin( distance( px + time, py, 0.5, 0.5 ) / 8.0 )
		             + sin( distance( px,       py, 0.25, 0.25 ) / 8.0 )
		             + sin( distance( px, py+time, 0.66, 0.25 ) / 7.0 )
		             + sin( distance( px, py, 0.66, 0.40 ) / 8.0 ), 1);

	}
]]

verticalrainbowshader = [[
	// helper function, please ignore
	number _hue(number s, number t, number h)
	{
	h = mod(h, 1.);
	number six_h = 6.0 * h;
	if (six_h < 1.) return (t-s) * six_h + s;
	if (six_h < 3.) return t;
	if (six_h < 4.) return (t-s) * (4.-six_h) + s;
	return s;
	}

	// input: vec4(h,s,l,a), with h,s,l,a = 0..1
	// output: vec4(r,g,b,a), with r,g,b,a = 0..1
	vec4 hsl_to_rgb(vec4 c)
	{
	if (c.y == 0)
		return vec4(vec3(c.z), c.a);

	number t = (c.z < .5) ? c.y*c.z + c.z : -c.y*c.z + (c.y+c.z);
	number s = 2.0 * c.z - t;
	return vec4(_hue(s,t,c.x + 1./3.), _hue(s,t,c.x), _hue(s,t,c.x - 1./3.), c.w);
	}

	extern number time;
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
	{
		number p1 = (screen_coords.x-400) / 100;
		number p2 = (screen_coords.y-300) / 100;
		number p3 = p1 * p2;
		//return hsl_to_rgb(vec4(sin(time/2),sin(time/1),sin(time/4),1) *
		//		vec4(sin(p3), sin(p3), sin(p3), 1));
		return hsl_to_rgb(vec4(p1, time, 0.5,1));
		//vec4 texcolor = Texel(texture, texture_coords);
		//return texcolor * color * vec4( 0.8, 0.8, 0.8, 1);
	}
]]

bulbs = [[
	extern number time;
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
	{
		number p1 = (screen_coords.x) / 100;
		number p2 = (screen_coords.y) / 100;
		return vec4(sin(p2*cos(time)),sin(p2*cos(time)),cos(p2*sin(time)),1.0) + vec4(sin(p1*cos(time)),cos(p1*sin(time)),sin(p1*cos(time)),1.0);
		//vec4 texcolor = Texel(texture, texture_coords);
		//return texcolor * color * vec4( 0.8, 0.8, 0.8, 1);
	}
]]

shadergradient = [[
	extern number time;
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
	{
		number p = (screen_coords.x) / 100;
		return vec4(screen_coords.y+150)/600 * vec4((1.0+sin(time))/2.0, abs(cos(time*3)), abs(sin(time*2)), 1.0);
	}
]]

