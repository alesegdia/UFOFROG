
local anim8 = require 'libs.anim8.anim8'
local Class = require 'libs.hump.class'
local inspect = require 'libs.inspect'

local helper_anim8 = require 'src.helpers.anim8'
local helper_boxedit = require 'src.helpers.boxedit'

require 'src.helpers.proxy'

local Lvl2Enemy = Class {
}

function Lvl2Enemy:init(world)

	self.world = world

	-- animation loading
	local g = helper_anim8.newGrid(Image.lvl2enemy, 2, 1)
	local dtn = 1

	local drtn = 0.5
	self.anim = anim8.newAnimation( g(1,1, 2,1), {0.1, 0.3} )

	self.body = {}
	world:add(self.body, 0, 0, Image.lvl2enemy:getWidth() / 2, Image.lvl2enemy:getHeight() / 1)

	self.isDead = false

end

function Lvl2Enemy:draw()
	local x, y, w, h = self.world:getRect( self.body )
	love.graphics.rectangle("line", x, y, w, h)
	self.anim:draw(Image.lvl2enemy, x, y)
end

function Lvl2Enemy:update(dt)

	print(self.isDead)
	self.anim:update(dt)

end

return Lvl2Enemy
