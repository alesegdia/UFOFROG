
local Timer = require "libs.hump.timer"
local tween = Timer.tween
local bump = require 'libs.bump'

require 'libs.functional'

local Lvl2Boss = require 'src.entities.lvl2boss'
local Lvl2Hero = require 'src.entities.lvl2hero'
local Lvl2Enemy = require 'src.entities.lvl2enemy'
local Lvl2Turtle = require 'src.entities.lvl2turtle'

scene2 = {}

local boss, hero, entities
local world
entities = {}

local spawnEnemy = function()
	local enemy = Lvl2Enemy( world )
	local turtle = Lvl2Turtle( world )
	table.insert(entities, enemy)
	table.insert(entities, turtle)
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
	table.insert(entities, Lvl2Boss( world ))
	table.insert(entities, Lvl2Hero( world ))
	Timer.every(1, function()
		spawnEnemy()
	end)
end

function scene2:update(dt)

	updateGroup(entities, dt)
	clearGroup(entities)

	Timer.update(dt)
end

function scene2:draw()
		drawGroup(entities)
end

