--
--
--  Created by Tilmann Hars
--  Copyright (c) 2014 Headchant. All rights reserved.
--

-- Set Library Folders
LIBRARYPATH = "libs"
LIBRARYPATH = LIBRARYPATH .. "."


-- Get the libs manually
--local strict    = require( LIBRARYPATH.."strict"            )
local slam      = require( LIBRARYPATH.."slam"              )
local Gamestate = require( LIBRARYPATH.."hump.gamestate"    )

require 'src.states.scene1'
require 'src.states.scene2'
require 'constants'

-- Handle some global variables that strict.lua may (incorrectly, ofcourse) complain about:
class_commons = nil
common = nil
no_game_code = nil
NO_WIDGET   = nil
TILED_LOADER_PATH = nil

function love.load(arg)
	math.randomseed(os.time())
	love.graphics.setDefaultFilter("nearest", "nearest")
	Gamestate.registerEvents()
	Gamestate.switch(scene2)
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
