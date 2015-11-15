
local Timer = require "libs.hump.timer"
local tween = Timer.tween
local bump = require 'libs.bump'

local Lvl2Boss = require 'src.entities.lvl2boss'

scene2 = {}

local boss
local world

function scene2:enter()
	world = bump.newWorld( 120 )
	boss = Lvl2Boss( world )
end

function scene2:update(dt)
	boss:update(dt)
end

function scene2:draw()
	boss:draw(dt)
end

