
local anim8 = require 'libs.anim8.anim8'
local Class = require 'libs.hump.class'
local inspect = require 'libs.inspect'

local helper_anim8 = require 'src.helpers.anim8'

local Lvl2Smoke = require 'src.entities.lvl2smoke'
local Lvl2Explosion = require 'src.entities.lvl2explosion'

local Timer = require "libs.hump.timer"
local tween = Timer.tween

require 'src.helpers.proxy'

local Lvl2Turtle = Class {
}

function Lvl2Turtle:init(world, stage)

	self.stage = stage
	self.world = world

	-- animation loading
	local g = helper_anim8.newGrid(Image.lvl2turtle, 5, 1)
	local dtn = 1

	local drtn = 0.5
	self.anim = anim8.newAnimation( g(1,1, 2,1, 3,1, 4,1, 5,1), {0.05, 0.05, 0.05, 0.05, 0.05} )

	self.body = { isEnemy = true, isTurtle = true, entity = self }
	world:add(self.body, 1000, love.math.random(0, 400), Image.lvl2turtle:getWidth() / 5, Image.lvl2turtle:getHeight() / 1)

	self.isDead = false
	self.speed = 750 * (1 + math.random())

	self.horDisplaceTimer = 0
	self.scaling = 1
	self.timer = 0

	self.timerHandle = Timer.every(0.01, function()
		local x, y, _, _ = self.world:getRect(self.body)
		table.insert(self.stage, Lvl2Smoke(x+140, y+70 + math.random(-10, 10), self.scaling, {r=255, g=255, b=255}, 1.2))
	end)

	self.x, self.y = 0, 0

	self.peohandle = Timer.every((750 / 3)/ self.speed, function()
		SfxWAV.lvl2peotortu:setVolume(0.2)
		love.audio.play(SfxWAV.lvl2peotortu)
	end)

end

function Lvl2Turtle:draw()
	local x, y, w, h = self.world:getRect( self.body )
	--love.graphics.rectangle("line", x, y, w, h)
	self.anim:draw(Image.lvl2turtle, x, y, 0, self.scaling, self.scaling)
end

local col_filter = function(item, other)
	if other.isBoss ~= true and not other.isEnemy ~= true then return nil end
	if other.isPlayer == true then return "cross" end
	if other.isBullet == true then return "cross" end
end

function Lvl2Turtle:die()
	self.world:remove(self.body)
	self:explode()
	Timer.cancel(self.timerHandle)
	Timer.cancel(self.peohandle)
end

function Lvl2Turtle:explode()

	local x = self.x
	local y = self.y

	Timer.cancel(self.timerHandle)
	Timer.after(0, function()
		table.insert(self.stage, Lvl2Explosion(x + 40 + math.random(10,20), y+40 + math.random(1,10), 0.75))
	end)
	Timer.after(0.2, function()
		table.insert(self.stage, Lvl2Explosion(x + 40, y + 40, 1))
	end)
	self.isDead = true
end

function Lvl2Turtle:update(dt)

	local x, y, _, _ = self.world:getRect(self.body)

	self.horDisplaceTimer = self.horDisplaceTimer + dt

	self.timer = self.timer + dt
	self.scaling = 1 + math.sin(self.timer * 10)/6

	if self.horDisplaceTimer > 0.01 then
		self.horDisplaceTimer = 0
		y = y + love.math.random(-5,5)
	end

	local aX, aY, cols, len = self.world:move(self.body, x - dt * self.speed, y, col_filter)

	self.x = aX
	self.y = aY

	if x < -400 then
		self.isDead = true
	end

	for i=1,len do
		local col = cols[i]
		if col.other.isBullet then
			self.isDead = true
			SfxWAV.explo:setVolume(0.5)
			SfxWAV.explo:stop()
			SfxWAV.explo:play()
		end
	end

	self.anim:update(dt)

end

return Lvl2Turtle
