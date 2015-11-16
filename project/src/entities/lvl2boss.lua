
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

local createFrameBodyData = function( world, provider, index )
	return {

		data = provider:eachFrameBox( index, function( box )
			local handler = {}
			world:add( handler, unpack(box.data) )
			return handler
		end ),

		setActive = function (self, active)
			for k,v in self.data do
				v.isActive = active
			end
		end,

		activate = function (self)
			self:setActive(true)
		end,

		deactivate = function (self)
			self:setActive(false)
		end,

	}
end

function Lvl2Boss:init(world)

	self.world = world

	-- physic definition loading
	local provider = helper_boxedit.newProvider('data/boss2_def.json', 2, 4)
	self.bodies = {}
	self.bodies[1] = createFrameBodyData( world, provider, coords_to_index(1, 1, 2) )
	self.bodies[2] = createFrameBodyData( world, provider, coords_to_index(1, 2, 2) )
	self.bodies[3] = createFrameBodyData( world, provider, coords_to_index(2, 2, 2) )

	-- animation loading
	local g = helper_anim8.newGrid(Image.lvl2boss, 2, 4)
	local dtn = 1
	self.anim = anim8.newAnimation( g(1,1, 1,2, 2,2), {dtn, dtn, 5.0} )

	local that = self
	self.anim:assignFrameStart(1, function(anim) that.currentBodyData = that.bodies[1] end)
	self.anim:assignFrameStart(2, function(anim) that.currentBodyData = that.bodies[2] end)
	self.anim:assignFrameStart(3, function(anim) that.currentBodyData = that.bodies[3] end)

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
