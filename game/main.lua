

require "camera"
require "shaderlib"
require "AnAL"
require "constants"
require "class"
require "explosion"
require "enemy"
require "huevos"
require "hero"
Timer = require "timer"
require "bullet"
require "scene1"
require "razzmathazz"
local GS = require "gamestate"


width = 800
height = 600

function love.conf(t)
	t.window.width = width
	t.window.height = height
	t.console = true
end

function drawBox( ent )
	love.graphics.rectangle( "fill", ent.x, ent.y, ent.anim:getWidth(), ent.anim:getHeight() )
end

function love.load()
local __newImage = love.graphics.newImage -- old function
function love.graphics.newImage( ... ) -- new function that sets nearest filter
   local img = __newImage( ... ) -- call old function with all arguments to this function
   img:setFilter( 'nearest', 'nearest' )
   return img
end
	upray_anim = newAnimation( love.graphics.newImage("upray.png"), 528, 208, 0.1, 3 )
	shader_bg = love.graphics.newShader( shadercombo )
	bgm = love.audio.newSource( "ufofrog_theme.mp3", "stream" )
	--love.audio.play(bgm)
	bgm:play()

	sfx_explo = love.audio.newSource( "explosion.mp3", "static" )
	sfx_shoot = love.audio.newSource( "shoot.mp3", "static" )
	sfx_exploinit = love.audio.newSource( "explosionstart.ogg", "static" )
	sfx_boom = love.audio.newSource( "boom.wav", "static" )
	sfx_ray = love.audio.newSource( "ray.mp3", "static" )
	sfx_ray:setLooping(true)

	sfx_explo:setVolume(0.5)
	sfx_shoot:setVolume(0.5)
	sfx_ray:setVolume(0.5)

	bar = newAnimation( love.graphics.newImage("bar.png"), 1, 24, 1, 1 )
	rayanim = newAnimation( love.graphics.newImage("ray.png"), 24,768, 1, 1 )
	protect = newAnimation( love.graphics.newImage("protect.png"), 104,104,1,1)

	camera:setBounds( 0, 0, width, height )

	GS.registerEvents()
	GS.switch(scene1)

end

function love.update(dt)




end


function love.draw() 


end
