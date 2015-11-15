
local anim8 = require 'libs.anim8.anim8'

local _newGrid = function(img, cols, rows)
	local w = img:getWidth()
	local h = img:getHeight()
	local tw = w / cols
	local th = h / rows
	local g = anim8.newGrid(tw, th, w, h)
	return g
end

return {
	newGrid = _newGrid
}
