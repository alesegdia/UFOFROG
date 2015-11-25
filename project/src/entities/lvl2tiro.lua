
local Class = require 'libs.hump.class'
local inspect = require 'libs.inspect'

local Lvl2Smoke = require 'src.entities.lvl2smoke'
local Lvl2Explosion = require 'src.entities.lvl2explosion'

local Timer = require "libs.hump.timer"
local tween = Timer.tween

require 'src.helpers.proxy'

local Lvl2Tiro = Class {
}

function Lvl2Tiro:init(world, stage, x, y, rotation, onDie)

	self.world = world
	self.stage = stage

	self.rotation = rotation

	self.dx = math.sin(rotation)
	self.dy = math.cos(rotation)

	self.body = { isBullet = true }
	world:add(self.body, x, y, Image.lvl2tiro:getWidth() / 5, Image.lvl2tiro:getHeight() / 1)

	self.isDead = false
	self.speed = 750

	self.onDie = onDie

end

function Lvl2Tiro:draw()
	local x, y, _, _ = self.world:getRect( self.body )
	love.graphics.draw(Image.lvl2tiro, x, y, -self.rotation + math.rad(90))
end

local col_filter = function(item, other)
	if other.isBoss and not other.isActive then return nil end
	return "cross"
end

function Lvl2Tiro:die()
	self.world:remove(self.body)
end

function Lvl2Tiro:update(dt)
	local x, y, _, _ = self.world:getRect(self.body)
	local aX, aY, cols, len = self.world:move(self.body, x + dt * self.speed * self.dx, y + dt * self.speed * self.dy, col_filter)

	for i=1,len do
		local col = cols[i]
		if col.other.isTurtle or col.other.isEnemy then
			col.other.entity.isDead = true
			self.isDead = true
			self.onDie()
		elseif col.other.isBossBox then
			self.isDead = true
			table.insert(self.stage, Lvl2Explosion(aX, aY, 0.5))
		end
	end

	if x > 850 then self.isDead = true end
end

return Lvl2Tiro
