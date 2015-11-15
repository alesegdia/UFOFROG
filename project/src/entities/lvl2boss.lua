
local anim8 = require 'libs.anim8.anim8'
local Class = require 'libs.hump.class'
local inspect = require 'libs.inspect'

local helper_anim8 = require 'src.helpers.anim8'

require 'src.helpers.proxy'

local Lvl2Boss = Class {
}

function Lvl2Boss:init()

	-- animation loading
	local g = helper_anim8.newGrid(Image.lvl2boss, 2, 4)
	local dtn = 0.05
	self.anim = anim8.newAnimation( g(1,1, 1,2, 2,2), {dtn, dtn, 5.0} )

end

function Lvl2Boss:draw()
	self.anim:draw(Image.lvl2boss, 0, 0)
end

function Lvl2Boss:update(dt)
	self.anim:update(dt)
end

return Lvl2Boss
