local level = Gamestate.new()

function level:init()
	level.header_image = love.graphics.newImage('images/header.png')
end

function level:enter( previous, levelData )
	Objects 			= {}
	commandQueue 	= {}
	commandQueue[ WALDO_RED ]	 = CommandQueue:new( WALDO_RED )
	commandQueue[ WALDO_GREEN ] = CommandQueue:new( WALDO_GREEN )
	
	currentWaldo = WALDO_RED
	waldos		 = {}
	
	--waldos[WALDO_BLUE] 	= Waldo:new( 0, 0, "Blue Waldo", WALDO_BLUE )
	--waldos[WALDO_BLUE]:setColor( 0, 150, 255 )
	waldos[WALDO_GREEN] 	= Waldo:new( 0, 0, "Green Waldo", WALDO_GREEN )
	waldos[WALDO_GREEN]:setColor( 55, 255, 55 )
	waldos[WALDO_RED] 	= Waldo:new( 0, 0, "Red Waldo", WALDO_RED )
	waldos[WALDO_RED]:setColor( 255, 55, 55 )
	
	dtTimer = 0
	waitingQueue = {}
	
	--self:loadLevelNumber(  1 )
	self:loadLevel( levelData )
	level_song:setLooping( false )
	
	self.fade = { a = 255 }
	Tween( 3, self.fade, { a = 0 }, 'inQuad' )
end

function level:leave()
	Objects = nil
	commandQueue = nil
	waldos = nil
	waitingQueue = nil
	currentLevel = nil
	collectgarbage()
end

function level:update( dt )
	Tween.update(dt)
	local dt = dt * GAME_SPEED
	
	for k, v in ipairs( Objects ) do
		v:update( dt )
	end
	
	dtTimer = dtTimer + dt
	if dtTimer >= 1 then
		dtTimer = 0
		commandQueue[WALDO_RED]:runCommand()
		commandQueue[WALDO_GREEN]:runCommand()
	end
	
	if menu_song:isStopped() and level_song:isStopped() then
		--level_song:play()
	end
end

function level:draw()
	local lg = love.graphics
	-- Draw grid lines.
	lg.setColor( 64, 64, 64 )
	lg.setLine( 1, 'rough' )
	for x = 0, 1024, TILE_SIZE do
		lg.line( x, 0, x, 768 )
	end
	for y = 0, 768, TILE_SIZE do
		lg.line( 0, y, 1024, y )
	end
	lg.setLine( 1, 'smooth' )
	
	-- Draw items.
	table.sort( Objects, function(a,b) return a.z < b.z end)
	for k, v in ipairs( Objects ) do v:draw() end
	
	-- Draw header image.
	lg.setColor( 255, 255, 255, 255 )
	lg.draw( self.header_image, 0, 0 )
	
	-- Draw commands.
	for k, v in pairs( commandQueue ) do v:draw( 0, (k*40)+7 ) end
	
	-- Draw currently selected waldo color.
	lg.setColor( waldos[currentWaldo].color )
	lg.setLine( 10, 'rough' )
	lg.line( 0, 0, 1024, 0 )
	
	for k, v in ipairs( commandButtons ) do
		v:draw( )
	end
	
	lg.setColor( 255,255,255,50 )
	lg.rectangle( 'fill', 512-25, 40, 50, 87 )
	
	-- draw fade in.
	lg.setColor( 255, 255, 255, self.fade.a )
	lg.rectangle( 'fill', 0, 0, 1024, 768 )
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
	return item
end

function resetLevel()
	-- Stop all command queues.
	for k,v in pairs( commandQueue ) do v:stop() end
	-- Reload all objects to their saved position.
	for k, v in ipairs( Objects ) do
		v:loadPos()
	end
	
	clearPaint()
	waitingQueue = {}
	Beholder.trigger("resetInputs")
end

function clearPaint()
	for i,v in ipairs( Objects ) do
		if instanceOf( Paint, v ) then
			table.remove( Objects, i )
			v:destroy()
		end
	end
end

function switchWaldo()
	if currentWaldo == WALDO_RED then
		currentWaldo = WALDO_GREEN
	else
		currentWaldo = WALDO_RED
	end
end

function level:mousepressed( x, y, key )
	
	for k, v in ipairs( Objects ) do
		v:mousepressed( x, y, key )
	end
	
	for k, v in ipairs( commandButtons ) do
		v:onMousePressed( x, y, key )
	end
end

function level:mousereleased( x, y, key )
	
	for k, v in ipairs( Objects ) do
		v:mousereleased( x, y, key )
	end
end

function level:keypressed( key, unicode )
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
	elseif key == 'escape' then
		Gamestate.switch( stateMenu )
	end
end

function level:loadLevelNumber( levelNumber )
	clearPaint()
	
	local levelData = loadfile(LEVEL_PATH .. 'level_' .. levelNumber .. '.lua')
	currentLevel = levelData()
	currentLevel.load()
	
	if currentLevel.enableAllButtons then
		Button.create()
	else
		Button.create( currentLevel.enabledButtons )
	end
	
	self.cash = 0
end

function level:loadLevel( levelData )
	self.cash = 0
	levelData.load()
	if levelData.enableAllButtons then
		Button.create()
	else
		Button.create( levelData.enabledButtons )
	end
end

function level:onOutputSuccessfull()
	self.cash = self.cash + 10
	print( "$" .. self.cash )
end

return level