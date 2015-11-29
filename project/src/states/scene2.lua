
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

local font3 = love.graphics.newFont("thin_pixel-7.ttf", 100)
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
	local enemy = Lvl2Enemy( world, entities )
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

local newEvent = function(text, time_to_launch, duration_, upgrade_fn)
	createNotifier(text, time_to_launch, duration_)
	epilepsyAt(time_to_launch, duration_, upgrade_fn)
end

local turtleSpawnHandler = {}
local enemySpawnHandler = {}

local setTurtleSpawnRate = function(new_rate)
	Timer.cancel(turtleSpawnHandler)
	turtleSpawnHandler = Timer.every(new_rate, spawnTurtle)
end

local setEnemySpawnRate = function(new_rate)
	Timer.cancel(enemySpawnHandler)
	enemySpawnHandler = Timer.every(new_rate, spawnEnemy)
end

local theme
local boss

function scene2:enter()
	boss = {}
	theme = love.audio.newSource("music/scene2theme.mp3")
	theme:setVolume(0.5)
	theme:play()
	shader_bg = love.graphics.newShader( shader_stage2 )
	shader_epi = love.graphics.newShader( shaderepi_effect )
	world = bump.newWorld( 120 )
	hero = Lvl2Hero( world, entities )
	table.insert(entities, hero)

	local t1, t2, t3, t4, t5, t6, t7 = 1, 11, 23, 30, 40, 60, 65
	--local t1, t2, t3, t4, t5, t6, t7 = 1, 2, 3, 4, 5, 6, 7

	-- learn to swim
	newEvent("repeat zx to boost\narrows to move", t1, 3, function() end)

	-- turtles begin to appear
	newEvent("these turtles\nseem harmless", t2, 3, function()
		setTurtleSpawnRate(0.5)
	end)

	-- you learnt to swim!
	newEvent("SPACE FROG MODE!\n(protip: HOLD SPACE)", t3, 3, function()
		hero:superMode()
		hero:giveShoot(18)
	end)

	newEvent("TOZODIANS!", t4, 1, function()
		setEnemySpawnRate(0.5)
	end)

	-- you learnt to shoot!
	newEvent("RAMBO FROG MODE!!!!11", t5, 3, function()
		hero:giveSuperShoot()
		setTurtleSpawnRate(0.1)
		setEnemySpawnRate(0.1)
	end)

	newEvent("WTF EVERYONE'S OUT", t6, 3, function()
		hero:giveSuperShoot()
		Timer.cancel(enemySpawnHandler)
		Timer.cancel(turtleSpawnHandler)
	end)

	newEvent("OH SHIT THAT'S WHY", t7, 1, function()
		boss = Lvl2Boss(world, entities)
		table.insert(entities, boss)
	end)

	self.timer = 0
end

local alfa = 0

function scene2:update(dt)

	if boss.killed then
		alfa = alfa + 50 * dt
		if alfa > 255 then alfa = 255 end
	end

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

	self.dt = dt
end

function scene2:drawGUI()

	-- draw health
	love.graphics.setColor(255, 0, 255, 255)
	for i = 1,hero.health do
		love.graphics.rectangle("fill", 10 + (i-1) * 300, 610, 200, 200)
	end

	love.graphics.setColor(0, 255, 255, 255)
	for i = 1,hero.shield do
		love.graphics.rectangle("fill", 10 + (i-1) * 150, -110, 100, 100)
	end

	love.graphics.setColor(255, 255, 0, 255)
	if hero.raybar == 500 then
		local v = math.sin(self.timer * 40)
		if v > 0 then
			love.graphics.setFont(font2)
		else
			love.graphics.setFont(font3)
		end
		love.graphics.printf("C", 20, 200, 100)
	end

	if hero.raybar == 500 or hero:isRayActive() then
		local t = math.sin(self.timer * 100)
		if t > 0 then
			love.graphics.setColor(255, 0, 255, 255)
		end
	end
	love.graphics.rectangle("fill", -200, 10, 180, hero.raybar)

	love.graphics.setColor(255, 255, 255, 255)
end

function scene2:draw()

	local yshake = 10
	if hero:isRayActive() then yshake = 40 end

	local realx = center.x + math.random() * 0
	local realy = center.y + math.random() * yshake

	if hero:hasTurbo() then
		cam:lookAt(realx, realy)
	end

	-- render background
	cam:attach()
		if epilepsy == false and not hero:isRayActive() then
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
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.setFont(font2)
			love.graphics.printf( v.text, 0, 0, 800, "center", 0, 1+math.sin(self.timer*20)/6, 1+math.sin(self.timer*20)/6)
			love.graphics.setColor(255, 255, 255, 255)
		end

		self:drawGUI()
	cam:detach()

	love.graphics.setColor(0,0,0,alfa)
	love.graphics.rectangle("fill", 0,0,1000,1000)
	love.graphics.setColor(255,255,255,255)
end

