
local anim8 = require 'libs.anim8.anim8'
local Class = require 'libs.hump.class'
local inspect = require 'libs.inspect'
local Timer = require "libs.hump.timer"
local tween = Timer.tween

local helper_anim8 = require 'src.helpers.anim8'
local helper_boxedit = require 'src.helpers.boxedit'

local Lvl2Smoke = require 'src.entities.lvl2smoke'
local Lvl2Tiro = require 'src.entities.lvl2tiro'

require 'src.helpers.proxy'

local MAX_BOOST = 5
local BOOST_DEC_FACTOR = 1
local BOOST_INC_FACTOR = 10

local Lvl2Ray = Class {
}

function Lvl2Ray:init(world)
	self.world = world
	self.body = { active = false, isRay = true }
	self.x = 0
	self.y = 0
	self.world:add(self.body, self.x, self.y, Image.lvl2ray:getWidth()-60, Image.lvl2ray:getHeight())
end

function Lvl2Ray:activate()
	self.body.active = true
end

function Lvl2Ray:deactivate()
	self.body.active = false
end

function Lvl2Ray:draw()
	if self.body.active then
		love.graphics.draw(Image.lvl2ray, self.x, self.y)
		local x, y, w, h = self.world:getRect(self.body)
		--love.graphics.rectangle("fill", x, y, w, h)
	end
end

local col_filter = function(item, other)
	if other.isEnemy or other.isTurtle or (other.isBoss and other.isActive) then
		return "cross"
	end
end

function Lvl2Ray:die()
end

function Lvl2Ray:update(dt)
	if self.body.active then
		local aX, aY, cols, len = self.world:move(self.body, self.x, self.y, col_filter)
		for i=1,len do
			local col = cols[i]
			if col.other.isTurtle or col.other.isEnemy then
				col.other.entity.isDead = true
			end
		end
	end
end

return Lvl2Ray
