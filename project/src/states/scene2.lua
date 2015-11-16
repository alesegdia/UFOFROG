
local Timer = require "libs.hump.timer"
local tween = Timer.tween
local bump = require 'libs.bump'

require 'libs.functional'

local Lvl2Boss = require 'src.entities.lvl2boss'
local Lvl2Hero = require 'src.entities.lvl2hero'
local Lvl2Enemy = require 'src.entities.lvl2enemy'
local Lvl2Turtle = require 'src.entities.lvl2turtle'

scene2 = {}

local boss, hero, enemies
local world
enemies = {}

local spawnEnemy = function()
	local enemy = Lvl2Enemy( world )
	local turtle = Lvl2Turtle( world )
	table.insert(enemies, enemy)
	table.insert(enemies, turtle)
	return enemy
end

local clearGroup = function(entities)
	local todel = filter(function (item) return item.isDead == false end, entities)
	for i=#entities,1,-1 do
		local v = entities[i]
		if v then
			if v.isDead then
				table.remove(entities, i)
			end
		end
	end
	print(#entities)
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
	Timer.every(1, function()
		spawnEnemy()
	end)
end

function scene2:update(dt)

	boss:update(dt)
	hero:update(dt)
	updateGroup(enemies, dt)
	clearGroup(enemies)

	Timer.update(dt)
end

function scene2:draw()
	boss:draw()
	hero:draw()
	drawGroup(enemies)
end

