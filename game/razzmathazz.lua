
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

