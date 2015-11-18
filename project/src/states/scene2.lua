
local Timer = require "libs.hump.timer"
local tween = Timer.tween
local bump = require 'libs.bump'
local cam 		= require (LIBRARYPATH.."hump.camera")

require 'libs.functional'

local Lvl2Boss = require 'src.entities.lvl2boss'
local Lvl2Hero = require 'src.entities.lvl2hero'
local Lvl2Enemy = require 'src.entities.lvl2enemy'
local Lvl2Turtle = require 'src.entities.lvl2turtle'
local Lvl2Explosion = require 'src.entities.lvl2explosion'

scene2 = {}

local font = love.graphics.newFont("thin_pixel-7.ttf", 50)
font:setFilter("nearest", "nearest", 0)

local font2 = love.graphics.newFont("thin_pixel-7.ttf", 120)
font2:setFilter("nearest", "nearest", 0)

local entities = {}
local world
local cam 		= cam.new(0,0,1,0)
local shader_bg, shader_epi
local shader_timer = 0
local shake_current = 0
local hero

local notifiers = {}

local createNotifier = function(text_, launch, duration_ )
	Timer.after(launch, function()
		table.insert(notifiers, { text = text_, duration = duration_  })
	end)
end

local clearNotifier = function(dt)
	map(function(element) element.duration = element.duration - dt end, notifiers)
	notifiers = filter(function(element) return element.duration > 0 end, notifiers)
end

local center = {
	x = love.graphics.getWidth() / 2,
	y = love.graphics.getHeight() / 2
}

entities = {}

local spawnTurtle = function()
	local turtle = Lvl2Turtle( world, entities )
	table.insert(entities, turtle)
	return turtle
end

local spawnEnemy = function()
	local enemy = Lvl2Enemy( world )
	table.insert(entities, enemy)
	return enemy
end

local clearGroup = function(entities)
	local todel = filter(function (item) return item.isDead == true end, entities)
	for i=#entities,1,-1 do
		local v = entities[i]
		if v then
			if v.isDead then
				v:die()
				table.remove(entities, i)
			end
		end
	end
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

local epilepsy = false

local epilepsyAt = function(spawn, duration, onStart)
	Timer.after(spawn, function()
		onStart()
		epilepsy = true
		Timer.after(duration, function() epilepsy = false end)
	end)
end

local firstTurtleSpawnHandler

function scene2:enter()
	shader_bg = love.graphics.newShader( shader_stage2 )
	shader_epi = love.graphics.newShader( shaderepi_effect )
	world = bump.newWorld( 120 )
	--table.insert(entities, Lvl2Boss( world ))
	hero = Lvl2Hero( world, entities )
	table.insert(entities, hero)

	-- learn to swim
	createNotifier("zxzxzxzximmm", 1, 4)

	-- you learnt to swim!
	epilepsyAt(20, 2, function() hero:superMode() end)
	createNotifier("LOOK MA!\nKNO TO ZXIM!", 20, 4)

	-- learn to shoot
	epilepsyAt(40, 2, function() hero:giveShoot() end)
	createNotifier("shoot... shoooot SHOOOOT!\n(pro tip: space)", 40, 4)

	-- you learnt to shoot!
	epilepsyAt(60, 2, function() hero:giveSuperShoot() end)
	createNotifier("SUPER BULLET FROG!!", 60, 4)

	Timer.after(10, function() firstTurtleSpawnHandler = Timer.every(1, spawnTurtle) end)
	Timer.after(60, function()
		Timer.cancel(firstTurtleSpawnHandler)
		Timer.every(0.05, spawnTurtle)
	end)

	self.timer = 0
end

function scene2:update(dt)

	self.timer = self.timer + dt

	updateGroup(entities, dt)
	clearGroup(entities)

	Timer.update(dt)

	clearNotifier(dt)

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

	local shader_speed = 1
	if hero:hasTurbo() then
		shader_speed = 2
	end

	shader_bg:send( "time", 	shader_timer )
	shader_bg:send( "angle", 	shader_pixel_rotation )
	shader_bg:send( "speed", 	shader_speed )
	shader_epi:send( "time", 	shader_timer )

	if not epilepsy then
	end

	print(world:countItems())

	self.dt = dt
end

function scene2:draw()

	local realx = center.x + math.random() * 0
	local realy = center.y + math.random() * 10

	if hero:hasTurbo() then
		cam:lookAt(realx, realy)
	end

	-- render background
	cam:attach()
		if epilepsy == false then
			love.graphics.setShader(shader_bg)
		else
			love.graphics.setShader(shader_epi)
		end
		love.graphics.rectangle("fill", -100, -100, center.x*2 + 200, center.y*2 + 200 )
		love.graphics.setShader()
	cam:detach()

	-- render stage
	cam:attach()
		drawGroup(entities)
		for k,v in pairs(notifiers) do
			love.graphics.setColor(255, 0, 200, 255)
			love.graphics.setFont(font2)
			love.graphics.printf( v.text, 0, 0, 800, "center", 0, 1+math.sin(self.timer*20)/6, 1+math.sin(self.timer*20)/6)
			love.graphics.setColor(255, 255, 255, 255)
		end
	cam:detach()
end

