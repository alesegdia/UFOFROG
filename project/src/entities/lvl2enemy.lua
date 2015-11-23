
local anim8 = require 'libs.anim8.anim8'
local Class = require 'libs.hump.class'
local inspect = require 'libs.inspect'

local helper_anim8 = require 'src.helpers.anim8'
local helper_boxedit = require 'src.helpers.boxedit'

local Timer = require "libs.hump.timer"
local tween = Timer.tween

local Lvl2Smoke = require 'src.entities.lvl2smoke'
local Lvl2Explosion = require 'src.entities.lvl2explosion'

require 'src.helpers.proxy'

local Lvl2Enemy = Class {
}

function Lvl2Enemy:init(world, stage, spawnMin, spawnMax)

	self.spawnMin = spawnMin or 0
	self.spawnMax = spawnMax or 400

	self.world = world
	self.stage = stage

	-- animation loading
	local g = helper_anim8.newGrid(Image.lvl2enemy, 2, 1)

	local drtn = 0.5
	self.anim = anim8.newAnimation( g(1,1, 2,1), {0.3, 0.1} )

	self.body = { isEnemy = true, entity = self, isBaba = true }
	world:add(self.body, 1200, love.math.random(self.spawnMin, self.spawnMax), Image.lvl2enemy:getWidth() / 2, Image.lvl2enemy:getHeight() / 1)

	self.isDead = false
	self.speed = 0

	local that = self
	Timer.every(0.4, function()
		that:advance()
	end)

end

function Lvl2Enemy:draw()
	local x, y, w, h = self.world:getRect( self.body )
	--love.graphics.rectangle("line", x, y, w, h)
	self.anim:draw(Image.lvl2enemy, x, y)
end

function Lvl2Enemy:explode()

	local x = self.x
	local y = self.y

	Timer.after(0, function()
		table.insert(self.stage, Lvl2Explosion(x + 40 + math.random(10,20), y+40 + math.random(1,10), 0.75))
	end)
	Timer.after(0.2, function()
		table.insert(self.stage, Lvl2Explosion(x + 40, y + 40, 1))
	end)
	self.isDead = true
end

function Lvl2Enemy:die()
	self.world:remove(self.body)
end

function Lvl2Enemy:advance()
	self.speed = 5000
	tween(0.4, self, { speed = 1000 }, 'out-expo' )
end

local col_filter = function(item, other)
	if other.isBoss ~= true and not other.isEnemy ~= true then return nil end
	if other.isPlayer == true or other.isBullet then return "cross" end
end

function Lvl2Enemy:update(dt)

	local x, y, _, _ = self.world:getRect(self.body)
	local aX, aY, len, cols = self.world:move(self.body, x - dt * self.speed, y, col_filter)

	self.x, self.y = aX, aY

	if x < -400 then self.isDead = true end

	if self.speed > 2000 then
			table.insert(self.stage, Lvl2Smoke(x+80, y+40, 0.8, {r=255, g=0, b=0}))
	end

	self.anim:update(dt)

end

return Lvl2Enemy
