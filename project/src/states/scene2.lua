
local Timer = require "libs.hump.timer"
local tween = Timer.tween
local bump = require 'libs.bump'
local cam 		= require (LIBRARYPATH.."hump.camera")

require 'libs.functional'

local Lvl2Boss = require 'src.entities.lvl2boss'
local Lvl2Hero = require 'src.entities.lvl2hero'
local Lvl2Enemy = require 'src.entities.lvl2enemy'
local Lvl2Turtle = require 'src.entities.lvl2turtle'

scene2 = {}

local boss, hero, entities
local world
local cam 		= cam.new(0,0,1,0)
local shader_bg
local shader_timer = 0
local shake_current = 0

local center = {
	x = love.graphics.getWidth() / 2,
	y = love.graphics.getHeight() / 2
}

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
	shader_bg = love.graphics.newShader( shadercombo )
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

	-- update shader timer
	shader_timer = shader_timer + dt * 10

	-- hotline effect
	local cam_scale = math.abs( 0.008 * math.sin( shader_timer / 10 ) ) + 0.9
	cam:lookAt( center.x, center.y )
	cam:zoomTo( cam_scale )
	cam:rotateTo( 0.05 * math.sin( shader_timer / 10 ) )

	-- divisor de intensidad para la epilepsia
	local shader_shake_intensity = 20
	local shader_shake_current = math.abs( shake_current / shader_shake_intensity )
	if shader_shake_current > 1 then shader_shake_current = 1 end

	-- rotacion para la psicodelia
	local shader_pixel_rotation = -0.1*math.sin(5+shader_timer/10)

	shader_bg:send( "time", 	shader_timer )
	shader_bg:send( "factor",	shader_shake_current )
	shader_bg:send( "angle", 	shader_pixel_rotation )

end

function scene2:draw()

	-- render background
	cam:attach()
		love.graphics.setShader(shader_bg)
		love.graphics.rectangle("fill", -100, -100, center.x*2 + 200, center.y*2 + 200 )
		love.graphics.setShader()
	cam:detach()

	-- render stage
	cam:attach()
		drawGroup(entities)
	cam:detach()
end

