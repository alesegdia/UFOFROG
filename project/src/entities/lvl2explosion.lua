
local anim8 = require 'libs.anim8.anim8'
local Class = require 'libs.hump.class'
local inspect = require 'libs.inspect'

local helper_anim8 = require 'src.helpers.anim8'

local Timer = require "libs.hump.timer"
local tween = Timer.tween

require 'src.helpers.proxy'

local Lvl2Explosion = Class {
}

function Lvl2Explosion:init(x, y, scale)


	-- animation loading
	local g = helper_anim8.newGrid(Image.lvl2explosion, 2, 2)

	self.flipX = math.random() < 0.5
	if self.flipX then self.flipX = 1 else self.flipX = -1 end

	self.flipY = math.random() < 0.5
	if self.flipY then self.flipY = 1 else self.flipY = -1 end

	self.x = x
	self.y = y

	self.scale = scale

	local drtn = 0.2
	self.anim = anim8.newAnimation( g(1,1, 2,1, 1,2, 2,2), {0.03, 0.03, 0.03, 0.03},
	function(anim, loops)
		self.isDead = true
	end)


	self.isDead = false

	Timer.after(2, function() self.isDead = true end)

end

function Lvl2Explosion:die()
end

function Lvl2Explosion:draw()
	self.anim:draw(Image.lvl2explosion, self.x, self.y, 0, self.flipX * self.scale, self.flipY * self.scale,
	Image.lvl2explosion:getHeight()		/4,
	Image.lvl2explosion:getWidth()		/4)
end

function Lvl2Explosion:update(dt)

	self.anim:update(dt)

end

return Lvl2Explosion
