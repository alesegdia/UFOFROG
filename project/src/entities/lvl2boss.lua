
local anim8 = require 'libs.anim8.anim8'
local Class = require 'libs.hump.class'
local inspect = require 'libs.inspect'

local Timer = require "libs.hump.timer"
local tween = Timer.tween

local helper_anim8 = require 'src.helpers.anim8'
local helper_boxedit = require 'src.helpers.boxedit'

local Lvl2Enemy = require 'src.entities.lvl2enemy'

require 'src.helpers.proxy'

local Lvl2Boss = Class {
}

local coords_to_index = function( c, r, cols )
	return (r-1) * (cols) + c
end

function Lvl2Boss:forAllBodies(f)
	for k,v in pairs(self.bodies) do
		v:each(f)
	end
end

function Lvl2Boss:loadBodies(num)
	local bodies = {}
	for i=1,num do
		local bodygroup = helper_boxedit.bump.createFrameBodyData( self.world, self.provider, i )
		table.insert(bodies, bodygroup)
	end
	return bodies
end

function Lvl2Boss:configBodiesForAnim(anim, bodies)
	for anim_frame,associated_body in pairs(bodies) do
		anim:assignFrameStart(anim_frame, function(animation)
			for k,v in pairs(self.bodies) do
				if k == associated_body then
					v:activate()
					self.currentBodyData = v
				else
					v:deactivate()
				end
			end
		end)
	end
end

function Lvl2Boss:configSpawn(new_rate, spawnMin, spawnMax)
	Timer.cancel(self.timerhandle)
	if new_rate > 0 then
		self.timerhandle = Timer.every(new_rate, function()
			table.insert(self.stage, Lvl2Enemy(self.world, self.stage, spawnMin, spawnMax))
		end)
	end
end

function Lvl2Boss:init(world, stage)

	self.world = world
	self.stage = stage
	print(self.stage)

	self.timerhandle = {}

	self.x = 800
	self.y = 0

	-- physic definition loading
	self.provider = helper_boxedit.newProvider('data/boss2_def.json', 2, 4)

	self.bodies = self:loadBodies(8)
	self:forAllBodies(function(element) element.isBoss = true end)

	local gdanger = helper_anim8.newGrid(Image.lvl2danger, 1, 2)
	self.dangeranim = anim8.newAnimation( gdanger(1,1, 1,2), {0.1, 0.1} )

	-- animation loading
	local g = helper_anim8.newGrid(Image.lvl2boss, 2, 4)
	local dtn = 1
	--self.anim = anim8.newAnimation( g(1,1, 1,2, 2,2), {2, 0.1, 5.0} )
	self.standanim = anim8.newAnimation( g(1,1, 2,1), {0.4, 0.4} )
	self.throwanim = anim8.newAnimation( g(2,2), { 1 } )
	self.anim = self.standanim

	self:configBodiesForAnim(self.standanim, {1, 2})
	self:configBodiesForAnim(self.throwanim, {4})

	self.currentBodyData = self.bodies[1]

	self.danger = "no"

	local theboss = self

	Timer.after(0.5, function()
		love.audio.play(SfxWAV.n4)
	end)

	self.states = {
		wandering = {
			timerhandle = {},
			hasFinished = false,
			enter = function(self)
				theboss.anim = theboss.standanim
				self.hasFinished = false
				local that = self
				self.timerhandle = tween(1, theboss, {y = -70, x = 430}, 'in-out-circ', function()
					self.timerhandle = tween(1, theboss, {y = 150, x = 430}, 'in-out-circ', function()
						that.hasFinished = true
					end)
				end)
			end,
			leave = function(self)
				Timer.cancel(self.timerhandle)
			end,
		},
		arriving = {
			timerhandle = {},
			hasFinished = false,
			enter = function(self)
				theboss:configSpawn(0)
				theboss.anim = theboss.standanim
				theboss.standanim:reset()
				self.hasFinished = false
				theboss.x = 800
				theboss.y = 100
				local that = self
				self.timerhandle = tween(5, theboss, {x = 430, y = 0}, "out-back", function()
					that.hasFinished = true
				end)
			end,
			leave = function(self)
				Timer.cancel(self.timerhandle)
			end
		},

		pushleft = {
			timerhandle = {},
			hasFinished = false,
			enter = function(self)
				theboss.throwanim:reset()
				theboss:configSpawn(0.05, 0, 400)
				theboss.anim = theboss.throwanim
				self.hasFinished = false
				local that = self
				self.timerhandle = tween(1, theboss, {x = -1500, y = theboss.y}, "linear", function()
					that.hasFinished = true
				end)
			end,
			leave = function(self)
				Timer.cancel(self.timerhandle)
			end
		},

		pushright = {
			timerhandle = {},
			hasFinished = false,
			enter = function(self)

				theboss.throwanim:reset()
				theboss.anim = theboss.throwanim
				self.hasFinished = false
				local that = self
				theboss.flip = true
				self.timerhandle = tween(1, theboss, {x = 800, y = theboss.y}, "linear", function()
					that.hasFinished = true
				end)

			end,
			leave = function(self)
				Timer.cancel(self.timerhandle)
				theboss.flip = false
			end
		},

		dangerright = {
			hasFinished = false,
			enter = function(self)
				theboss.danger = "right"
				local that = self
				self.hasFinished = false
				local ypos = math.random(0, 350)
				theboss.y = ypos
				Timer.after(1, function()
					that.hasFinished = true
				end)
				SfxWAV.lvl2danger:setVolume(0.5)
				--love.audio.setPosition(0,0,0)
				--SfxWAV.lvl2danger:setPosition(-1, 0, 0)
				love.audio.play(SfxWAV.lvl2danger)
				Timer.after(0.3, function() love.audio.play(SfxWAV.lvl2danger) end)
				Timer.after(0.6, function() love.audio.play(SfxWAV.lvl2danger) end)
				Timer.after(0.9, function() love.audio.play(SfxWAV.lvl2danger) end)
			end,
			leave = function(self)
				theboss.danger = "no"
			end
		},

		dangerleft = {
			hasFinished = false,
			enter = function(self)
				theboss.danger = "left"
				self.hasFinished = false
				local that = self
				local ypos = math.random(0, 350)
				theboss.y = ypos
				Timer.after(1, function()
					that.hasFinished = true
				end)
				--SfxWAV.lvl2danger:setVolume(0.5)
				--SfxWAV.lvl2danger:setPosition(1, 0, 0)
				love.audio.setPosition(0,0,0)
				love.audio.play(SfxWAV.lvl2danger)
				Timer.after(0.3, function() love.audio.play(SfxWAV.lvl2danger) end)
				Timer.after(0.6, function() love.audio.play(SfxWAV.lvl2danger) end)
				Timer.after(0.9, function() love.audio.play(SfxWAV.lvl2danger) end)
			end,
			leave = function(self)
				theboss.danger = "no"
			end
		},

		hiding = {
			timerhandle = {},
			hasFinished = false,
			enter = function(self)
				theboss.standanim:reset()
				theboss.anim = theboss.standanim
				self.hasFinished = false
				local that = self
				self.timerhandle = tween(2, theboss, {x = 800, y = 0}, "linear", function()
					that.hasFinished = true
				end)
			end,
			leave = function(self)
				Timer.cancel(self.timerhandle)
			end
		}

	}

	self.behaviour_cycle = {
		self.states.arriving,
		self.states.wandering,
		self.states.wandering,
		self.states.wandering,
		self.states.hiding,
		self.states.dangerright,
		self.states.pushleft,
		self.states.dangerleft,
		self.states.pushright,
	}

	local that = self
	self.co = coroutine.create(function()
		while true do
			for k,v in pairs(that.behaviour_cycle) do
				that:changeState(v)
				coroutine.yield()
				while not v.hasFinished do
					coroutine.yield()
				end
			end
		end
	end)

	self.currentState = self.states.arriving
	self:changeState(self.states.arriving)

	self.health = 3

	self.timer = 0
end

function Lvl2Boss:changeState(newState)
	self.currentState:leave()
	self.currentState = newState
	self.currentState:enter()
end

function Lvl2Boss:explode()

end

function Lvl2Boss:dealtDamage()
	if not self.invulnerable then
		self.health = self.health - 1
		if self.health < 1 then
			self.isDead = true
		end
		self.invulnerable = true
		Timer.after(3, function() self.invulnerable = false end)
		SfxWAV.n3:play()
	end
end

function Lvl2Boss:die()

end

function Lvl2Boss:draw()

	if self.invulnerable then
		local alfa = math.sin(self.timer*20)
		if alfa > 0 then
			love.graphics.setColor(255,255,255,0)
		else
			love.graphics.setColor(255,255,255,255)
		end
	else
		love.graphics.setColor(255,255,255,255)
	end

	for k,v in pairs(self.currentBodyData.data) do
		local x, y, w, h = self.world:getRect(v)
		--love.graphics.rectangle("line", x, y, w, h)
	end

	if self.danger == "left" then
		self.dangeranim:draw(Image.lvl2danger, 0, self.y + 120)
	elseif self.danger == "right" then
		self.dangeranim:draw(Image.lvl2danger, 800 - Image.lvl2danger:getWidth(), self.y + 120)
	end

	--love.graphics.setColor(255, 255, 0, 255)
	if self.flip then
		local anx, any = self.anim:getDimensions()
		self.anim:draw(Image.lvl2boss, self.x + anx, self.y, 0, -1, 1)
	else
		self.anim:draw(Image.lvl2boss, self.x, self.y)
	end
	--love.graphics.setColor(255, 255, 255, 255)
end

local col_filter = function(item, other)
	if item.isActive then return "cross" end
	return nil
end

function Lvl2Boss:update(dt)
	self.timer = self.timer + dt
	coroutine.resume(self.co)
	self.anim:update(dt)
	self.dangeranim:update(dt)
	self.currentBodyData:each( function( element )
		local aX, aY = self.world:getRect(element)
		local newx, newy
		newy = element.y + self.y
		if self.flip then
			local animx, _ = self.anim:getDimensions()
			newx = self.x + animx - element.x
		else
			newx = element.x + self.x
		end
		local aX, aY, cols, len = self.world:move(element, newx, newy, col_filter)
		for i=1,len do
			local col = cols[i]
			if col.other.isRay and element.isActive and element.name == "weak" and col.other.active then
				self:dealtDamage()
			end
		end
	end )
end

return Lvl2Boss
