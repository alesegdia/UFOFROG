

require "camera"
require "shaderlib"
require "AnAL"
require "constants"
require "class"
require "explosion"
require "enemy"
require "huevos"
require "hero"
Timer = require "hump.timer"
require "bullet"
require "scene1"
require "razzmathazz"
local GS = require "gamestate"

-- Creates a proxy via rawset.
-- Credit goes to vrld: https://github.com/vrld/Princess/blob/master/main.lua
-- easier, faster access and caching of resources like images and sound
-- or on demand resource loading
local function Proxy(f)
	return setmetatable({}, {__index = function(self, k)
		local v = f(k)
		rawset(self, k, v)
		return v
	end})
end

-- some standard proxies
Image   = Proxy(function(k) return love.graphics.newImage('media/' .. k .. '.png') end)
SfxOGG  = Proxy(function(k) return love.audio.newSource('media/' .. k .. '.ogg', 'static') end)
SfxMP3  = Proxy(function(k) return love.audio.newSource('media/' .. k .. '.mp3', 'static') end)
SfxWAV  = Proxy(function(k) return love.audio.newSource('media/' .. k .. '.wav', 'static') end)
MusicOGG = Proxy(function(k) return love.audio.newSource('media/' .. k .. '.ogg', 'stream') end)
MusicMP3 = Proxy(function(k) return love.audio.newSource('media/' .. k .. '.mp3', 'stream') end)

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
	upray_anim = newAnimation( Image.upray, 528, 208, 0.1, 3 )
	shader_bg = love.graphics.newShader( shadercombo )
	bgm = MusicMP3.ufofrog_theme
	--love.audio.play(bgm)
	bgm:play()

	sfx_explo = SfxMP3.explosion
	sfx_shoot = MusicMP3.shoot
	sfx_exploinit = SfxOGG.explosionstart
	sfx_boom = SfxWAV.boom
	sfx_ray = SfxMP3.ray
	sfx_ray:setLooping(true)

	sfx_explo:setVolume(0.5)
	sfx_shoot:setVolume(0.5)
	sfx_ray:setVolume(0.5)

	bar = newAnimation( Image.bar, 1, 24, 1, 1 )
	rayanim = newAnimation( Image.ray, 24,768, 1, 1 )
	protect = newAnimation( Image.protect, 104,104,1,1)

	camera:setBounds( 0, 0, width, height )

	GS.registerEvents()
	GS.switch(scene1)

end

function love.update(dt)




end


function love.draw()


end
