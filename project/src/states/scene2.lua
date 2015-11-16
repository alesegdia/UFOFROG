
local Timer = require "libs.hump.timer"
local tween = Timer.tween
local bump = require 'libs.bump'

require 'libs.functional'

local Lvl2Boss = require 'src.entities.lvl2boss'
local Lvl2Hero = require 'src.entities.lvl2hero'
local Lvl2Enemy = require 'src.entities.lvl2enemy'

scene2 = {}

local boss, hero, enemies
local world
enemies = {}

local spawnEnemy = function(x, y)
	local enemy = Lvl2Enemy( world )
	table.insert(enemies, enemy)
	return enemy
end

local clearEnemies = function()
	enemies = filter(function (item) return item.isDead == false end, enemies)
end

local updateGroup = function(tbl, dt)
	for _,item in ipairs(tbl) do
		item:update(dt)
	end
end

local drawGroup = function(tbl, dt)
	for _,item in ipairs(tbl) do
		item:draw(dt)
	end
end

function scene2:enter()
	world = bump.newWorld( 120 )
	boss = Lvl2Boss( world )
	hero = Lvl2Hero( world )
	enemy = spawnEnemy(0,0)
end

function scene2:update(dt)

	boss:update(dt)
	hero:update(dt)
	updateGroup(enemies, dt)
	clearEnemies()

	Timer.update(dt)
end

function scene2:draw()
	boss:draw()
	hero:draw()
	drawGroup(enemies)
end

