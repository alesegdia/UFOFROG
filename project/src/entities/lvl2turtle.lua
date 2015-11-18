
local anim8 = require 'libs.anim8.anim8'
local Class = require 'libs.hump.class'
local inspect = require 'libs.inspect'

local helper_anim8 = require 'src.helpers.anim8'
local helper_boxedit = require 'src.helpers.boxedit'

local Lvl2Smoke = require 'src.entities.lvl2smoke'

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

	self.body = { isEnemy = true }
	world:add(self.body, 1000, love.math.random(0, 400), Image.lvl2turtle:getWidth() / 5, Image.lvl2turtle:getHeight() / 1)

	self.isDead = false
	self.speed = 750 * (1 + math.random())

	self.horDisplaceTimer = 0
	self.scaling = 1
	self.timer = 0

	local that = self
	self.timerHandle = Timer.every(0.01, function()
		local x, y, _, _ = that.world:getRect(that.body)
		table.insert(that.stage, Lvl2Smoke(x+140, y+70 + math.random(-10, 10), that.scaling, {r=255, g=255, b=255}, 0.5))
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

	self.world:move(self.body, x - dt * self.speed, y, col_filter)

	if x < -400 then
		self.isDead = true
		Timer.cancel(self.timerHandle)
	end

	self.anim:update(dt)

end

return Lvl2Turtle
