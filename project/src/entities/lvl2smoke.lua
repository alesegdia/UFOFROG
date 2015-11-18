
local Class = require 'libs.hump.class'

local Lvl2Smoke = Class {}

function Lvl2Smoke:init(x, y, scale, color, dx)

	if dx == nil then
		self.dx = 1
	else
		self.dx = dx
	end

	if color == nil then
		self.color = { r = 255, g = 255, b = 255 }
	else
		self.color = color
	end

	self.size = math.random(20,40) * scale
	self.x, self.y = x, y
	self.timer = 0

	local thesign = 1
	if math.random() < 0.5 then thesign = -1 end
	self.rotspeed = math.random() * 4 * thesign
	self.rotation = math.random() * 360
end

function Lvl2Smoke:update(dt)
	self.x = self.x - dt * 500 * self.dx
	self.timer = self.timer + dt
	if self.timer > 1 then
		self.isDead = true
	end
	self.y = self.y + dt * 100 * math.random()
	self.rotation = self.rotation + self.rotspeed * dt

	self.size = self.size - (dt * 50 * (1-self.timer))
end

function Lvl2Smoke:draw()
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, 255 - 255 * (self.timer/1) )

	love.graphics.push()

	love.graphics.translate(self.x, self.y)
	love.graphics.rotate(self.rotation)
	love.graphics.translate(-self.size/2, -self.size/2)
	love.graphics.rectangle("fill", 0, 0, self.size, self.size)

	love.graphics.pop()

	love.graphics.setColor(255, 255, 255, 255)
end

return Lvl2Smoke
