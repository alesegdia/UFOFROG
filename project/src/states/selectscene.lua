
local Timer = require "libs.hump.timer"
local tween = Timer.tween

local Gamestate = require( LIBRARYPATH.."hump.gamestate"    )

require 'src.states.scene1'
require 'src.states.scene2'

local font = love.graphics.newFont("thin_pixel-7.ttf", 120)
font:setFilter("nearest", "nearest", 0)

selectscene = {}

function selectscene:enter()
	love.graphics.setFont(font)
end

function selectscene:update(dt)
	if love.keyboard.isDown("1") then Gamestate.switch(scene1) end
	if love.keyboard.isDown("2") then Gamestate.switch(scene2) end
end

function selectscene:draw()

	love.graphics.printf("1. birthday", 100, 100, 700)
	love.graphics.printf("2. learning", 100, 200, 700)

end

