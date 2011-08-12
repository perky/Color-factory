vector 		= require "vector"
Timer  		= require "Timer"
Ringbuffer 	= require "Ringbuffer"
require "middleclass.init"
require "middleclass-extras.init"
require "COLORS"
require "Waldo"
require "Paint"
require "CommandQueue"
require "InputOutput"
require "Sensor"
require "Box"
require "Boxer"
require "Unboxer"
require "Mixer"
require "Conveyor"

TAU = 2 * math.pi

GAME_SPEED = 1
TILE_SIZE = 64

WALDO_RED 	= 0
WALDO_GREEN = 1
WALDO_BLUE	= 2

UP 			= 0
RIGHT 		= 1
DOWN 			= 2
LEFT 			= 3

function love.load()
	math.randomseed( os.time() )
	love.graphics.setMode( 1024, 768 )
	love.graphics.setBackgroundColor( 34, 34, 34 )
	header_image = love.graphics.newImage('images/header.png')
	
	Objects 		= {}
	Commands1		= CommandQueue:new( WALDO_GREEN )
	Commands2		= CommandQueue:new( WALDO_RED )
	Commands = Commands1
	
	currentWaldo = WALDO_GREEN
	waldos		 = {}
	
	waldos[WALDO_BLUE] 	= Waldo:new( 0, 0, "Blue Waldo" )
	waldos[WALDO_BLUE]:setColor( 0, 150, 255 )
	waldos[WALDO_GREEN] 	= Waldo:new( 0, 0, "Green Waldo" )
	waldos[WALDO_GREEN]:setColor( 55, 255, 55 )
	waldos[WALDO_RED] 	= Waldo:new( 0, 0, "Red Waldo" )
	waldos[WALDO_RED]:setColor( 255, 55, 55 )
	
	loadLevel( 1 )
	
	
	-- Create buttons.
	commandButtons = {}
	local n = 0
	for i = 0, 13 do
		if CommandQueue.commandImages[i] then
			local button = Button:new( CommandQueue.commandImages[i], 15+n*34, 12, i )
			table.insert(commandButtons, button)
			n = n + 1
		end
	end
end

function setupWaldo( waldoColor, gridX, gridY, length, direction )
	waldos[waldoColor]:setup( gridX, gridY, length, direction )
	waldos[waldoColor].disabled = false
end

function removeWaldo( waldoColor )
	waldos[waldoColor].disabled = true
end

function addItem( className, gridX, gridY, ... )
	item = className:new()
	item:setup( gridX, gridY, ... )
end

function loadLevel( levelNumber )
	Commands.commands.current = Commands.commands:size()
	Commands.state = STOPPED
	clearPaint()
	
	loadedLevel = loadfile('levels/level_' .. levelNumber .. '.lua')
	currentLevel = loadedLevel()
end

function level1()
	Commands.commands.current = Commands.commands:size()
	Commands.state = STOPPED
	clearPaint()
	
	waldos[WALDO_RED]:setup( 3, 5, 2, 'left' )
	waldos[WALDO_GREEN]:setup( 3, 7, 2, 'right' )
	waldos[WALDO_BLUE]:setup( 5, 7, 2, 'right' )
	Input:setup( 1, 5, IO_IN )
	Output:setup( 12, 12, IO_OUT, DETECTS_COLOR, PAINT_ORANGE )
	--Output2:setup( 3, 4, IO_OUT, DETECTS_QUANTITY, 6 )
	--SensorGreen:setup( 3, 3, DETECTS_COLOR, PAINT_RED )
	--SensorQuantity:setup( 1, 7, DETECTS_COLOR, PAINT_RED )
	--SensorQuantity2:setup( 2, 7, DETECTS_QUANTITY, 6 )
	--SensorQuantity3:setup( 2, 6, DETECTS_QUANTITY, 3 )
	--boxer:setup( 4, 5 )
	--boxer2:setup( 5, 5 )
	mixer:setup( 4, 5 )
end

function resetLevel()
	Commands.commands.current = Commands.commands:size()
	Commands.state = STOPPED
	clearPaint()
	
	for k, v in ipairs( Objects ) do
		v:loadPos()
	end
end

function clearPaint()
	for i,v in ipairs( Objects ) do
		if instanceOf( Paint, v ) then
			table.remove( Objects, i )
			v:destroy()
		end
	end
end

function love.update( dt )
	local dt = dt * GAME_SPEED
	for k, v in ipairs( Objects ) do
		v:update( dt )
	end
	Timer.update( dt )
end

function love.draw()
	-- Draw grid lines.
	love.graphics.setColor( 64, 64, 64 )
	love.graphics.setLine( 1, 'rough' )
	for x = 0, 1024, TILE_SIZE do
		love.graphics.line( x, 0, x, 768 )
	end
	for y = 0, 768, TILE_SIZE do
		love.graphics.line( 0, y, 1024, y )
	end
	love.graphics.setLine( 1, 'smooth' )
	
	-- Draw items.
	for i = #Objects, 1, -1 do
		Objects[i]:draw()
	end
	
	-- Draw header image.
	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.draw( header_image, 0, 0 )
	
	-- Draw commands.
	Commands1:draw()
	Commands2:draw()
	
	-- Draw currently selected waldo color.
	love.graphics.setColor( waldos[currentWaldo].color )
	love.graphics.setLine( 10, 'rough' )
	love.graphics.line( 0, 0, 1024, 0 )
	
	for k, v in ipairs( commandButtons ) do
		v:draw( )
	end
end

function switchWaldo()
--[[
	currentWaldo = currentWaldo + 1
	if currentWaldo > WALDO_BLUE then
		currentWaldo = WALDO_RED
	end
	--]]
	if currentWaldo == WALDO_RED then
		currentWaldo = WALDO_GREEN
		Commands = Commands1
	else
		currentWaldo = WALDO_RED
		Commands = Commands2
	end
end

function love.mousepressed( x, y, key )
	for k, v in ipairs( Objects ) do
		v:mousepressed( x, y, key )
	end
	
	for k, v in ipairs( commandButtons ) do
		v:onMousePressed( x, y, key )
	end
	
	Commands:onMousePressed( x, y, key )
end

function love.mousereleased( x, y, key )
	for k, v in ipairs( Objects ) do
		v:mousereleased( x, y, key )
	end
end

function love.keypressed( key, unicode )
	if key == 'tab' then
		switchWaldo()
	elseif key == 'q' then
		Commands:addCommand( currentWaldo, CMD_ROTATE_CCW )
	elseif key == 'w' then
		Commands:addCommand( currentWaldo, CMD_GRABDROP )
	elseif key == 'e' then
		Commands:addCommand( currentWaldo, CMD_ROTATE_CW )
	elseif key == 'r' then
		Commands:addCommand( currentWaldo, CMD_EXTEND )
	elseif key == 'i' then
		Commands:addCommand( currentWaldo, CMD_INPUT )
	elseif key == 'o' then
		Commands:addCommand( currentWaldo, CMD_OUTPUT )
	elseif key == 'a' then
		Commands:addCommand( currentWaldo, CMD_SENSE )
	elseif key == 's' then
		Commands:addCommand( currentWaldo, CMD_JUMP )
	elseif key == 'd' then
		Commands:addCommand( currentWaldo, CMD_LOOP )
	elseif key == ' ' then
		Commands1:toggleRun()
		Commands2:toggleRun()
	elseif key == '.' then
		resetLevel(  )
	elseif key == 'up' then
		GAME_SPEED = GAME_SPEED * 2
	elseif key == 'down' then
		GAME_SPEED = GAME_SPEED / 2
	elseif key == 'backspace' then
		Commands:removeCommand()
	elseif key == 't' then
		Commands:addCommand( currentWaldo, CMD_VERTICAL )
	elseif key == 'f' then
		Commands:addCommand( currentWaldo, CMD_HORIZONTAL )
	elseif key == 'left' then
		Commands.commands:prev()
	elseif key == 'right' then
		Commands.commands:next()
	elseif key == 'x' then
		Commands:addCommand( currentWaldo, CMD_JUMPOUT )
	end
end