
function dot_product( x1, y1, x2, y2 )
	return x1 * x2 + y1 * y2
end

function rotate_vector( px, py, cx, cy, angle )
	local s, c, xnew, ynew, ppx, ppy
	s = math.sin(angle)
	c = math.cos(angle)
	ppx = px - cx;
	ppy = py - cy;
	xnew = ppx * c - ppy * s
	ynew = ppx * s + ppy * c
	return { x = xnew + cx, y = ynew + cy }
end

function signo(num)
	if num >= 0 then return 1 end
	return -1
end

function normalize(vx, vy)
	local mod = vecmod(vx,vy)
	return  { x = vx / mod, y = vy / mod }
end

function vecmod(vx, vy)
	return math.sqrt((vx * vx) + (vy * vy))
end


function collision_aabb(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end


function collision_point_obb( xo,yo,wo,ho, px,py, angle )
	local newpoint = rotate_vector( 0,0,px,py,math.pi/2 + angle )
	local newy = newpoint.y--math.sin(angle) * (py - yo) + math.cos(angle) * (px - xo)
	local newx = newpoint.x--math.cos(angle) * (px - xo) - math.sin(angle) * (py - yo)
	return newy > yo and newy < yo + ho and newx > xo and newx < xo
end

function distance_point_line( Ax, Ay, Bx, By, Px, Py )
	--local slope = (p1.y - p2.y) / (p1.x - p2.x)
	--return math.abs(A*m + B*n + C)/math.sqrt(A*A+B*B)
	local normal_length = math.sqrt( (Bx-Ax)*(Bx-Ax) + (By-Ay)*(By-Ay) )
	return math.abs((Px-Ax)*(By-Ay) - (Py-Ay)*(Bx-Ax))/ normal_length
end

function distance_point_point( Ax, Ay, Bx, By )
	return math.sqrt((Ax-Bx)*(Ax-Bx)+(Ay-By)*(Ay-By))
end
