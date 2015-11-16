
local anim8 = require 'libs.anim8.anim8'
local Class = require 'libs.hump.class'
local inspect = require 'libs.inspect'

local helper_anim8 = require 'src.helpers.anim8'
local helper_boxedit = require 'src.helpers.boxedit'

local Timer = require "libs.hump.timer"
local tween = Timer.tween

require 'src.helpers.proxy'

local Lvl2Enemy = Class {
}

function Lvl2Enemy:init(world)

	self.world = world

	-- animation loading
	local g = helper_anim8.newGrid(Image.lvl2enemy, 2, 1)
	local dtn = 1

	local drtn = 0.5
	self.anim = anim8.newAnimation( g(1,1, 2,1), {0.3, 0.1} )

	self.body = { isEnemy = true }
	world:add(self.body, 1000, love.math.random(0, 600), Image.lvl2enemy:getWidth() / 2, Image.lvl2enemy:getHeight() / 1)

	self.isDead = false
	self.speed = 0

	local that = self
	Timer.every(0.4, function()
		that:advance()
	end)

end

function Lvl2Enemy:draw()
	local x, y, w, h = self.world:getRect( self.body )
	love.graphics.rectangle("line", x, y, w, h)
	self.anim:draw(Image.lvl2enemy, x, y)
end

function Lvl2Enemy:advance()
	self.speed = 400
	tween(0.4, self, { speed = 200 }, 'out-expo' )
end

local col_filter = function(item, other)
	if other.isBoss ~= true and not other.isEnemy ~= true then return nil end
	if other.isPlayer == true then return "cross" end
end

function Lvl2Enemy:update(dt)

	local x, y, _, _ = self.world:getRect(self.body)
	self.world:move(self.body, x - dt * self.speed, y, col_filter)

	self.anim:update(dt)

end

return Lvl2Enemy
