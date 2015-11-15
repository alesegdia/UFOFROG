
local Timer				= require (LIBRARYPATH.."hump.timer")
local tween       = Timer.tween

local Lvl2Boss = require 'src.entities.lvl2boss'


scene2 = {}

local boss

function scene2:enter()
	boss = Lvl2Boss()
end

function scene2:update(dt)
end

function scene2:draw()
end

