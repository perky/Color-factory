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

WALDO_RED 	= 1
WALDO_GREEN = 2
WALDO_BLUE	= 3

UP 			= 0
RIGHT 		= 1
DOWN 			= 2
LEFT 			= 3

function love.load()
	math.randomseed( os.time() )
	love.graphics.setMode( 1024, 768 )
	love.graphics.setBackgroundColor( 34, 34, 34 )
	header_image = love.graphics.newImage('images/header.png')
	
	Objects 			= {}
	commandQueue 	= {}
	commandQueue[ WALDO_RED ]	 = CommandQueue:new( WALDO_RED )
	commandQueue[ WALDO_GREEN ] = CommandQueue:new( WALDO_GREEN )
	
	currentWaldo = WALDO_RED
	waldos		 = {}
	
	waldos[WALDO_BLUE] 	= Waldo:new( 0, 0, "Blue Waldo", WALDO_BLUE )
	waldos[WALDO_BLUE]:setColor( 0, 150, 255 )
	waldos[WALDO_GREEN] 	= Waldo:new( 0, 0, "Green Waldo", WALDO_GREEN )
	waldos[WALDO_GREEN]:setColor( 55, 255, 55 )
	waldos[WALDO_RED] 	= Waldo:new( 0, 0, "Red Waldo", WALDO_RED )
	waldos[WALDO_RED]:setColor( 255, 55, 55 )
	
	dtTimer = 0
	waitingQueue = {}
	
	loadLevel( 1 )
end

function nextTick()
	Beholder.trigger('nextTick')
end

function setupWaldo( waldoColor, gridX, gridY, length, direction )
	waldos[waldoColor]:setup( gridX, gridY+2, length, direction )
	waldos[waldoColor].disabled = false
end

function removeWaldo( waldoColor )
	waldos[waldoColor].disabled = true
end

function addItem( className, gridX, gridY, ... )
	item = className:new()
	item:setup( gridX, gridY+2, ... )
end

function loadLevel( levelNumber )
	clearPaint()
	
	loadedLevel = loadfile('levels/level_' .. levelNumber .. '.lua')
	currentLevel = loadedLevel()
	Button.create( currentLevel.enabledButtons )
end

function resetLevel()
	for k,v in pairs( commandQueue ) do v:stop() end
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
	
	dtTimer = dtTimer + dt
	if dtTimer >= 1 then
		dtTimer = 0
		commandQueue[WALDO_RED]:runCommand()
		commandQueue[WALDO_GREEN]:runCommand()
	end
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
	table.sort( Objects, function(a,b) return a.z < b.z end)
	for k, v in ipairs( Objects ) do v:draw() end
	
	-- Draw header image.
	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.draw( header_image, 0, 0 )
	
	-- Draw commands.
	for k, v in pairs( commandQueue ) do v:draw( 0, (k*40)+7 ) end
	
	-- Draw currently selected waldo color.
	love.graphics.setColor( waldos[currentWaldo].color )
	love.graphics.setLine( 10, 'rough' )
	love.graphics.line( 0, 0, 1024, 0 )
	
	for k, v in ipairs( commandButtons ) do
		v:draw( )
	end
	
	love.graphics.setColor( 255,255,255,50 )
	love.graphics.rectangle( 'fill', 512-25, 40, 50, 87 )
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
	else
		currentWaldo = WALDO_RED
	end
end

function love.mousepressed( x, y, key )
	for k, v in ipairs( Objects ) do
		v:mousepressed( x, y, key )
	end
	
	for k, v in ipairs( commandButtons ) do
		v:onMousePressed( x, y, key )
	end
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
		commandQueue[currentWaldo]:addCommand( CMD_ROTATE_CCW )
	elseif key == 'w' then
		commandQueue[currentWaldo]:addCommand( CMD_GRABDROP )
	elseif key == 'e' then
		commandQueue[currentWaldo]:addCommand( CMD_ROTATE_CW )
	elseif key == 'r' then
		commandQueue[currentWaldo]:addCommand( currentWaldo, CMD_EXTEND )
	elseif key == 'i' then
		commandQueue[currentWaldo]:addCommand( currentWaldo, CMD_INPUT )
	elseif key == 'o' then
		commandQueue[currentWaldo]:addCommand( currentWaldo, CMD_OUTPUT )
	elseif key == 'a' then
		commandQueue[currentWaldo]:addCommand( currentWaldo, CMD_SENSE )
	elseif key == 's' then
		commandQueue[currentWaldo]:addCommand( currentWaldo, CMD_JUMP )
	elseif key == 'd' then
		commandQueue[currentWaldo]:addCommand( currentWaldo, CMD_LOOP )
	elseif key == ' ' then
		for k, v in pairs( commandQueue ) do v:toggleRun() end
	elseif key == '.' then
		resetLevel(  )
	elseif key == 'up' then
		GAME_SPEED = GAME_SPEED * 2
	elseif key == 'down' then
		GAME_SPEED = GAME_SPEED / 2
	elseif key == 'backspace' then
		commandQueue[currentWaldo]:removeCommand()
	elseif key == 't' then
		commandQueue[currentWaldo]:addCommand( currentWaldo, CMD_VERTICAL )
	elseif key == 'f' then
		commandQueue[currentWaldo]:addCommand( currentWaldo, CMD_HORIZONTAL )
	elseif key == 'left' then
		commandQueue[currentWaldo]:prev()
	elseif key == 'right' then
		commandQueue[currentWaldo]:next()
	elseif key == 'x' then
		commandQueue[currentWaldo]:addCommand( currentWaldo, CMD_JUMPOUT )
	end
end