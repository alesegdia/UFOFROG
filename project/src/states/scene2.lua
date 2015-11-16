
local Timer = require "libs.hump.timer"
local tween = Timer.tween
local bump = require 'libs.bump'

local Lvl2Boss = require 'src.entities.lvl2boss'
local Lvl2Hero = require 'src.entities.lvl2hero'

scene2 = {}

local boss, hero
local world

function scene2:enter()
	world = bump.newWorld( 120 )
	boss = Lvl2Boss( world )
	hero = Lvl2Hero( world )
end

function scene2:update(dt)
	boss:update(dt)
	hero:update(dt)
end

function scene2:draw()
	boss:draw()
	hero:draw()
end

