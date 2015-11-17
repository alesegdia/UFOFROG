
local anim8 = require 'libs.anim8.anim8'
local Class = require 'libs.hump.class'
local inspect = require 'libs.inspect'

local helper_anim8 = require 'src.helpers.anim8'
local helper_boxedit = require 'src.helpers.boxedit'

require 'src.helpers.proxy'

local MAX_BOOST = 5
local BOOST_DEC_FACTOR = 1
local BOOST_INC_FACTOR = 10

local Lvl2Hero = Class {
}

function Lvl2Hero:init(world)

	self.world = world

	-- animation loading
	local g = helper_anim8.newGrid(Image.lvl2hero, 2, 3)
	local dtn = 1

	local drtn = 0.5
	self.swim_anim = anim8.newAnimation( g(2,1, 1,1, 2,2, 1,1), {drtn, drtn, drtn, drtn} )
	self.stand_anim = anim8.newAnimation( g(1,1), {1} )

	self.boost = 0
	self.lastpress = "z"
	self.speed = { x = 75, y = 50 }

	self.body = { isPlayer = true }
	world:add(self.body, 0, 0, Image.lvl2hero:getWidth() / 2, Image.lvl2hero:getHeight() / 3)

end

function Lvl2Hero:draw()
	local x, y, w, h = self.world:getRect( self.body )
	--love.graphics.rectangle("line", x, y, w, h)
	self.anim:draw(Image.lvl2hero, x, y)
end

local col_filter = function(item, other)
	if other.isEnemy then return "cross" end
	if other.isBoss and other.isActive == true then return "cross" end
end

function Lvl2Hero:update(dt)

	-- movement boost control
	local zpress = love.keyboard.isDown("z")
	local xpress = love.keyboard.isDown("x")

	if zpress and self.lastpress == "x" or xpress and self.lastpress == "z" then
		self.boost = self.boost + dt * BOOST_INC_FACTOR
	else
		self.boost = self.boost - dt * BOOST_DEC_FACTOR
	end
	if self.boost > MAX_BOOST then self.boost = MAX_BOOST end
	if self.boost <= 0 then self.boost = 0 end

	if zpress then self.lastpress = "z" end
	if xpress then self.lastpress = "x" end

	-- animation depends on movement
	local newanim
	if self.boost == 0 then newanim = self.stand_anim
	else newanim = self.swim_anim end

	-- reset animation if changes
	if newanim ~= self.anim then
		newanim.timer = 0
	end

	self.anim = newanim

	-- check keyboard input
	local up, down, left, right
	up = love.keyboard.isDown("up")
	down = love.keyboard.isDown("down")
	left = love.keyboard.isDown("left")
	right = love.keyboard.isDown("right")

	-- compute displacement from keyboard input
	local dx, dy
	dx = 0
	dy = 0

	if up then dy = -1 end
	if down then dy = 1 end
	if up and down then dy = 0 end

	if left then dx = -1 end
	if right then dx = 1 end
	if left and right then dx = 0 end

	-- perform movement
	local x, y, _, _ = self.world:getRect( self.body )
	local aX, aY, cols, len = self.world:move( self.body,
		x + dx * self.boost * self.speed.x * dt,
		y + dy * self.boost * self.speed.y * dt,
		col_filter
	)

	self.anim:update(dt * self.boost)

end

return Lvl2Hero
