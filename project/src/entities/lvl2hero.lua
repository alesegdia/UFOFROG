
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

local Lvl2Hero = Class {
}

function Lvl2Hero:init(world, stage)

	self.stage = stage
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
	world:add(self.body, 600, 300, Image.lvl2hero:getWidth() / 2, Image.lvl2hero:getHeight() / 3)

	local that = self
	self.swim_anim:assignFrameStart(1, function()
		if not self.supermode then
		if self.boost > 0 then
			local x, y, _, _ = that.world:getRect(that.body)
			table.insert(self.stage, Lvl2Smoke(x+20, y+20, 0.8, {r=0, g=255, b=255}))
		end
		end
	end)

	self.swim_anim:assignFrameStart(3, function()
		if not self.supermode then
		if self.boost > 0 then
			local x, y, _, _ = that.world:getRect(that.body)
			table.insert(self.stage, Lvl2Smoke(x+15, y+40, 0.8, {r=0, g=255, b=255}))
		end
		end
	end)

	self.rotation = 0
	self.tw = Image.lvl2hero:getWidth() / 2
	self.th = Image.lvl2hero:getHeight() / 3

	self.resistance = 200

	self.nextShoot = 1

	self.canShoot = false

	self.cooldown = 1

end

function Lvl2Hero:giveSuperShoot()
	self.cooldown = 0.02
end

function Lvl2Hero:giveShoot()
	self.canShoot = true
	tween(20, self, { cooldown = 0.1 })
end

function Lvl2Hero:superMode()
	self.supermode = true
	self.resistance = 100

	Timer.every(0.03, function()
		local x, y, _, _ = self.world:getRect(self.body)
		--table.insert(self.stage, Lvl2Smoke(x+40 + math.random()*10, y+40 + math.random()*10, 1, {r=0, g=255, b=255}))
		--table.insert(self.stage, Lvl2Smoke(x+50 + math.random()*10, y+40 + math.random()*10, 2.5, {r=0, g=255, b=255}, 2))
		table.insert(self.stage, Lvl2Smoke(x+30 + math.random()*10, y+40 + math.random()*10, 2, {r=0, g=255, b=255}, 2))
	end)
end

function Lvl2Hero:draw()
	local x, y, w, h = self.world:getRect( self.body )
	--love.graphics.rectangle("line", x, y, w, h)
	self.anim:draw(Image.lvl2hero, x+self.tw/2, y+self.th/2, self.rotation, 1, 1, self.tw/2, self.th/2)
end

function Lvl2Hero:hasTurbo()
	return self.supermode
end

-- IF COLLIDE WITH TURTLE, RESISTANCE BOOST WHILE COLLIDING
local col_filter = function(item, other)
	if other.isEnemy then
		return "cross"
	end
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

	if self.supermode == true then
		self.anim = self.swim_anim
		self.boost = 8

		local x, y, _, _ = self.world:getRect(self.body)
		--table.insert(self.stage, Lvl2Smoke(x+40 + math.random()*10, y+40 + math.random()*10, 1, {r=0, g=255, b=255}))
	end

	-- check keyboard input
	local up, down, left, right
	up = love.keyboard.isDown("up")
	down = love.keyboard.isDown("down")
	left = love.keyboard.isDown("left")
	right = love.keyboard.isDown("right")

	if not up and not down and not left and not right then
		self.anim = self.stand_anim
	end

	if self.supermode then
		self.anim = self.swim_anim
	end

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

	if self.boost > 0 then
		if up and not down then self.rotation = math.rad(-20) end
		if not up and down then self.rotation = math.rad(20) end
		if not up and not down then self.rotation = 0 end
	else
		self.rotation = 0
	end

	-- perform movement
	local x, y, _, _ = self.world:getRect( self.body )
	local newx, newy
	newx = -dt * self.resistance + x + dx * self.boost * self.speed.x * dt
	newy = y + dy * self.boost * self.speed.y * dt


	if newx < -30 then newx = -30 end
	if newx > 800 then newx = 800 end

	if newy < -30 then newy = -30 end
	if newy > 580 then newy = 580 end

	local aX, aY, cols, len = self.world:move( self.body, newx, newy, col_filter )

	self.anim:update(dt * self.boost)

	if self.nextShoot >= 0 then
		self.nextShoot = self.nextShoot - dt
	end

	local letShoot = self.nextShoot < 0

	if love.keyboard.isDown(" ") and self.canShoot and letShoot then
		self.nextShoot = self.cooldown
		local range = math.random(-10,10)
		table.insert(self.stage, Lvl2Tiro(self.world, aX+40, aY+40, math.rad(90 + range) - self.rotation))
	end

end

return Lvl2Hero
