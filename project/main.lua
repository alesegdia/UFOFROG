--
--
--  Created by Tilmann Hars
--  Copyright (c) 2014 Headchant. All rights reserved.
--

-- Set Library Folders
LIBRARYPATH = "libs"
LIBRARYPATH = LIBRARYPATH .. "."


-- Get the libs manually
local strict    = require( LIBRARYPATH.."strict"            )
local slam      = require( LIBRARYPATH.."slam"              )
local Gamestate = require( LIBRARYPATH.."hump.gamestate"    )

require 'src.states.scene1'
require 'constants'

-- Handle some global variables that strict.lua may (incorrectly, ofcourse) complain about:
class_commons = nil
common = nil
no_game_code = nil
NO_WIDGET   = nil
TILED_LOADER_PATH = nil

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
Image   = Proxy(function(k) return love.graphics.newImage('img/' .. k .. '.png') end)
SfxOGG  = Proxy(function(k) return love.audio.newSource('sfx/' .. k .. '.ogg', 'static') end)
SfxMP3  = Proxy(function(k) return love.audio.newSource('sfx/' .. k .. '.mp3', 'static') end)
SfxWAV  = Proxy(function(k) return love.audio.newSource('sfx/' .. k .. '.wav', 'static') end)
MusicOGG = Proxy(function(k) return love.audio.newSource('music/' .. k .. '.ogg', 'stream') end)
MusicMP3 = Proxy(function(k) return love.audio.newSource('music/' .. k .. '.mp3', 'stream') end)

-- Initialization
function love.load(arg)
	math.randomseed(os.time())
	love.graphics.setDefaultFilter("nearest", "nearest")
	Gamestate.registerEvents()
	Gamestate.switch(scene1)
end

-- Logic
function love.update( dt )

end

-- Rendering
function love.draw()

end

-- Input
function love.keypressed()

end

function love.keyreleased()

end

function love.mousepressed()

end

function love.mousereleased()

end

function love.joystickpressed()

end

function love.joystickreleased()

end

io.stdout:setvbuf("no")
