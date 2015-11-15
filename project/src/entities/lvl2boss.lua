
local anim8 = require 'libs.anim8.anim8'
local Class = require 'libs.hump.class'
local inspect = require 'libs.inspect'

local helper_anim8 = require 'src.helpers.anim8'
local helper_boxedit = require 'src.helpers.boxedit'

require 'src.helpers.proxy'

local Lvl2Boss = Class {
}

local createFrameBodyData = function( provider, nframe )
	return {

		data = provider:eachFrameBox( nframe, function( box )
			local handler = {}
			--world:add( handler, unpack(box.data) )
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

function Lvl2Boss:init()

	-- physic definition loading
	local provider = helper_boxedit.newProvider('data/boss2_def.json', 2, 4)
	self.bodies = {}
	self.bodies[1] = createFrameBodyData( provider, 1 )
	self.bodies[2] = createFrameBodyData( provider, 2 )
	self.bodies[3] = createFrameBodyData( provider, 3 )

	-- animation loading
	local g = helper_anim8.newGrid(Image.lvl2boss, 2, 4)
	local dtn = 0.05
	self.anim = anim8.newAnimation( g(1,1, 1,2, 2,2), {dtn, dtn, 5.0} )

	local that = self
	self.anim:assignFrameStart(1, function(anim) that.currentBodyData = that.bodies[1] end)
	self.anim:assignFrameStart(2, function(anim) that.currentBodyData = that.bodies[2] end)
	self.anim:assignFrameStart(3, function(anim) that.currentBodyData = that.bodies[3] end)

end

function Lvl2Boss:draw()
	self.anim:draw(Image.lvl2boss, 0, 0)
end

function Lvl2Boss:update(dt)
	self.anim:update(dt)
end

return Lvl2Boss
