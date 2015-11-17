
local Class = require 'libs.hump.class'

local Lvl2Smoke = Class {}

function Lvl2Smoke:init(x, y, scale)
	self.size = math.random(20,40) * scale
	self.x, self.y = x, y
	self.timer = 0

	local thesign = 1
	if math.random() < 0.5 then thesign = -1 end
	self.rotspeed = math.random() * 4 * thesign
	self.rotation = 0
end

function Lvl2Smoke:update(dt)
	self.timer = self.timer + dt
	if self.timer > 1 then
		self.isDead = true
	end
	self.y = self.y + dt * 100 * math.random()
	self.rotation = self.rotation + self.rotspeed * dt

	self.size = self.size - (dt * 50 * (1-self.timer))
end

function Lvl2Smoke:draw()
	love.graphics.setColor(255, 255, 255, 255 - 255 * (self.timer/1) )

	love.graphics.push()

	love.graphics.translate(self.x, self.y)
	love.graphics.rotate(self.rotation)
	love.graphics.translate(-self.size/2, -self.size/2)
	love.graphics.rectangle("fill", 0, 0, self.size, self.size)

	love.graphics.pop()

	love.graphics.setColor(255, 255, 255, 255)
end

return Lvl2Smoke
