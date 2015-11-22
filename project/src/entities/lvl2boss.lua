
local anim8 = require 'libs.anim8.anim8'
local Class = require 'libs.hump.class'
local inspect = require 'libs.inspect'

local Timer = require "libs.hump.timer"
local tween = Timer.tween

local helper_anim8 = require 'src.helpers.anim8'
local helper_boxedit = require 'src.helpers.boxedit'

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

function Lvl2Boss:configBodiesForAnim()
	for k,v in pairs(self.bodies) do
		self.anim:assignFrameStart(k, function(anim)
			for k2,v2 in pairs(self.bodies) do
				if k2 == k then
					v2:activate()
					self.currentBodyData = v2
				else
					v2:deactivate()
				end
			end
		end)
	end
end

function Lvl2Boss:init(world)

	self.world = world

	self.x = 800

	self.y = 0

	-- physic definition loading
	self.provider = helper_boxedit.newProvider('data/boss2_def.json', 2, 4)

	self.bodies = self:loadBodies(8)
	self:forAllBodies(function(element) element.isBoss = true end)

	-- animation loading
	local g = helper_anim8.newGrid(Image.lvl2boss_nocolor, 2, 4)
	local dtn = 1
	--self.anim = anim8.newAnimation( g(1,1, 1,2, 2,2), {2, 0.1, 5.0} )
	self.anim = anim8.newAnimation( g(1,1, 2,1), {0.4, 0.4} )

	self:configBodiesForAnim()

	self.currentBodyData = self.bodies[1]

	local theboss = self

	self.states = {
		wandering = {
			timerhandle = {},
			hasFinished = false,
			enter = function(self)
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
				self.hasFinished = false
				self.x = 800
				self.y = 0
				local that = self
				self.timerhandle = tween(5, theboss, {x = 430, y = 0}, "out-back", function()
					that.hasFinished = true
				end)
			end,
			leave = function(self)
				Timer.cancel(self.timerhandle)
			end
		},

	}

	self.behaviour_cycle = {self.states.arriving, self.states.wandering, self.states.wandering, self.states.wandering}

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
end

function Lvl2Boss:changeState(newState)
	self.currentState:leave()
	self.currentState = newState
	self.currentState:enter()
end

function Lvl2Boss:explode()

end

function Lvl2Boss:draw()
	for k,v in pairs(self.currentBodyData.data) do
		local x, y, w, h = self.world:getRect(v)
		love.graphics.rectangle("line", x, y, w, h)
	end
	--love.graphics.setColor(255, 255, 0, 255)
	self.anim:draw(Image.lvl2boss_nocolor, self.x, self.y)
	--love.graphics.setColor(255, 255, 255, 255)
end

local col_filter = function(item, other)
	if item.isActive then return "cross" end
	return nil
end

function Lvl2Boss:update(dt)
	coroutine.resume(self.co)
	self.anim:update(dt)
	self.currentBodyData:each( function( element )
		local aX, aY = self.world:getRect(element)
		local newx = element.x + self.x
		local newy = element.y + self.y
		self.world:move(element, newx, newy, col_filter)
	end )
end

return Lvl2Boss
