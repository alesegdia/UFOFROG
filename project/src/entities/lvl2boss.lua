
local anim8 = require 'libs.anim8.anim8'
local Class = require 'libs.hump.class'
local inspect = require 'libs.inspect'

local helper_anim8 = require 'src.helpers.anim8'
local helper_boxedit = require 'src.helpers.boxedit'

require 'src.helpers.proxy'

local Lvl2Boss = Class {
}

local coords_to_index = function( c, r, cols )
	return (r-1) * (cols) + c
end

function Lvl2Boss:init(world)

	self.world = world

	-- physic definition loading
	local provider = helper_boxedit.newProvider('data/boss2_def.json', 2, 4)
	self.bodies = {}
	self.bodies[1] = helper_boxedit.bump.createFrameBodyData( world, provider, coords_to_index(1, 1, 2) )
	self.bodies[1]:each( function( element ) element.isBoss = true end )

	self.bodies[2] = helper_boxedit.bump.createFrameBodyData( world, provider, coords_to_index(1, 2, 2) )
	self.bodies[2]:each( function( element ) element.isBoss = true end )

	self.bodies[3] = helper_boxedit.bump.createFrameBodyData( world, provider, coords_to_index(2, 2, 2) )
	self.bodies[3]:each( function( element ) element.isBoss = true end )

	-- animation loading
	local g = helper_anim8.newGrid(Image.lvl2boss, 2, 4)
	local dtn = 1
	self.anim = anim8.newAnimation( g(1,1, 1,2, 2,2), {dtn, dtn, 5.0} )

	local that = self
	self.anim:assignFrameStart(1, function(anim)
		that.currentBodyData = that.bodies[1]
		that.bodies[1]:activate()
		that.bodies[2]:deactivate()
		that.bodies[3]:deactivate()
	end)

	self.anim:assignFrameStart(2, function(anim)
		that.currentBodyData = that.bodies[2]
		that.bodies[1]:deactivate()
		that.bodies[2]:activate()
		that.bodies[3]:deactivate()
	end)

	self.anim:assignFrameStart(3, function(anim)
		that.currentBodyData = that.bodies[3]
		that.bodies[1]:deactivate()
		that.bodies[2]:deactivate()
		that.bodies[3]:activate()
	end)

	self.currentBodyData = self.bodies[1]

end

function Lvl2Boss:draw()
	for k,v in pairs(self.currentBodyData.data) do
		local x, y, w, h = self.world:getRect(v)
		love.graphics.rectangle("line", x, y, w, h)
	end
	self.anim:draw(Image.lvl2boss, 0, 0)
end

function Lvl2Boss:update(dt)
	self.anim:update(dt)
end

return Lvl2Boss
