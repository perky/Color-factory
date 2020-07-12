GAME_VERSION = "0.13"

vector 		= require "util.vector"
Timer  		= require "util.timer"
Ringbuffer 	= require "util.ringbuffer"
Gamestate	= require "util.gamestate"
Tween			= require "util.tween"
Arc 			= require "util.arcchart"
require "middleclass.init"
require "middleclass-extras.init"
require "COLORS"
require "CommandQueue"
require "items.Node"
require "items.Waldo"
require "items.Paint"
require "items.InputOutput"
require "items.Sensor"
require "items.Box"
require "items.Boxer"
require "items.Unboxer"
require "items.Mixer"
require "items.Conveyor"
require "items.Input"
require "items.Output"
require "AnAL.AnAL"
-- require 'luahub.init'
--require 'gamestats.gamestats'

TAU = 2 * math.pi

LEVEL_PATH = "levels/"
GAME_SPEED = 2
TILE_SIZE = 64

WALDO_RED 	= 1
WALDO_GREEN = 2
WALDO_BLUE	= 3

UP 			= 0
RIGHT 		= 1
DOWN 			= 2
LEFT 			= 3

stateSplash = require "states.splash"
stateMenu	= require "states.menu"
stateLevel 	= require "states.level"

-- checkupdates_thread = love.thread.newThread( 'checkupdates', 'checkupdates-thread.lua' )
-- checkupdates_thread:start()
-- checkupdates_thread:send( 'GAME_VERSION', GAME_VERSION )

function love.load()
	math.randomseed( os.time() )
	-- setup screen mode.
	love.graphics.setMode( 1024, 768, false, false, 4 )
	screenOffset = { x = 0, y = 0 }
	isFullscreen = false
	love.graphics.setBackgroundColor( 34, 34, 34 )
	
	-- Set the write directory
	love.filesystem.setIdentity("colorfactory")
	-- create the custom levels folder if it doesn't exist.
	if not love.filesystem.exists( "customlevels" ) then
		love.filesystem.mkdir( "customlevels" )
		local templatefile = love.filesystem.newFile( "customlevels/customtemplate.lua" )
		templatefile:open('w')
		for line in love.filesystem.lines( "customtemplate.lua" ) do
		   templatefile:write( line .. "\n" )
		end
		templatefile:close()
	end
	
	splash_song 	= love.audio.newSource( 'sound/intro.ogg', 'static' )
	menu_song 		= love.audio.newSource( 'sound/menu_loop.ogg', 'static' )
	flash_sound		= love.audio.newSource( 'sound/flash.ogg', 'static' )
	menu_song:setLooping( true )
	love.audio.setVolume( 0.45 )
	
	Gamestate.registerEvents()
	Gamestate.switch( stateMenu )
	
	-- start game session.
	-- gamestats:game_session_start()
end

function love.quit()
   -- finish game session.
   -- gamestats:setBlocking( true )
   -- gamestats:game_session_end()
end

function love.update( dt )
   --gamestats:update( dt )
end

local _mouseGetX = love.mouse.getX
local _mouseGetY = love.mouse.getY
function love.mouse.getX()
	return _mouseGetX() - screenOffset.x
end
function love.mouse.getY()
	return _mouseGetY() - screenOffset.y
end

function love.keypressed( key, unicode )
	if key == 'f12' then
		toggleFullscreen()
	elseif key == 'm' then
		local volume = love.audio.getVolume( )
		if volume > 0 then
			love.audio.setVolume(0)
		else
			love.audio.setVolume(0.45)
		end
	end
end

function toggleFullscreen( )
	if isFullscreen then
		isFullscreen = false
		love.graphics.setMode( 1024, 768, false, false, 8 )
		screenOffset = { x = 0, y = 0 }
	else
		isFullscreen = true
		love.graphics.setMode( 0, 0, true, false, 8 )
		local x = love.graphics.getWidth()/2 - 1024/2
		local y = love.graphics.getHeight()/2 - 768/2
		screenOffset = { x = x, y = y }
	end
end

function table.copy( tbl )
	local copy = {}
	for k, v in ipairs( tbl ) do copy[k] = v end
	return copy
end

function table.shuffle( tbl )
	local newPos
	for i = #tbl, 2, -1 do
		newPos = math.random(i)
		tbl[i], tbl[newPos] = tbl[newPos], tbl[i]
	end
end
