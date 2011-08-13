require "Button"

CommandQueue = class("CommandQueue")
CommandQueue:include(Beholder)

CMD_ROTATE_CW	=	0
CMD_ROTATE_CCW	=	1
CMD_GRABDROP	=	2
CMD_EXTEND		=	3
CMD_HORIZONTAL = 	4
CMD_VERTICAL	= 	5
CMD_WAIT			= 	6
CMD_SENSE		=	7
CMD_JUMP			=	8
CMD_JUMPOUT		= 	9
CMD_LOOP			= 10
CMD_INPUT		= 11
CMD_OUTPUT		= 12
CMD_GRAB			= 13
CMD_DROP			= 14


STOPPED			= 0
PLAYING			= 1
PAUSED			= 2

function CommandQueue:initialize( waldoColor )
	self.commands = {}
	self.commandsPos = 1
	
	self.running = false
	self.state = STOPPED
	self.loopPoints = {}
	self:observe('fireSensorTrue', CommandQueue.sensorJump, self)
	self:observe('nextTick', CommandQueue.runCommand, self)
	self.commandingWaldo = waldoColor
end

function CommandQueue.loadImages()
	CommandQueue.commandImages = {}
	CommandQueue.commandImages[CMD_ROTATE_CW] = love.graphics.newImage( 'images/cw.png' )
	CommandQueue.commandImages[CMD_ROTATE_CCW] = love.graphics.newImage( 'images/ccw.png' )
	CommandQueue.commandImages[CMD_EXTEND] = love.graphics.newImage( 'images/extend.png' )
	CommandQueue.commandImages[CMD_GRABDROP] = love.graphics.newImage( 'images/grabdrop.png' )
	CommandQueue.commandImages[CMD_SENSE] = love.graphics.newImage( 'images/sense.png' )
	CommandQueue.commandImages[CMD_JUMP] = love.graphics.newImage( 'images/jump.png' )
	CommandQueue.commandImages[CMD_LOOP] = love.graphics.newImage( 'images/loop.png' )
	CommandQueue.commandImages[CMD_INPUT] 			= love.graphics.newImage( 'images/input.png' )
	CommandQueue.commandImages[CMD_OUTPUT] 		= love.graphics.newImage( 'images/output.png' )
	CommandQueue.commandImages[CMD_HORIZONTAL] 	= love.graphics.newImage( 'images/horizontal.png' )
	CommandQueue.commandImages[CMD_VERTICAL] 		= love.graphics.newImage( 'images/vertical.png' )
	CommandQueue.commandImages[CMD_JUMPOUT] 		= love.graphics.newImage( 'images/jumpout.png' )
	CommandQueue.commandImages[CMD_WAIT] 			= love.graphics.newImage( 'images/wait.png' )
end
CommandQueue.loadImages()

function CommandQueue:addCommand( command )
	if #self.commands < 1 then
		self.commandsPos = 1
	else
		self.commandsPos = self.commandsPos + 1
	end
	table.insert(self.commands, self.commandsPos, command )
end

function CommandQueue:removeCommand( pos )
	if #self.commands <= 0 then return end
	table.remove( self.commands, self.commandsPos )
	if self.commandsPos > #self.commands then
		self.commandsPos = self.commandsPos - 1
	end
end

function CommandQueue:draw( x, y )
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.setColor( waldos[self.commandingWaldo].color )
	love.graphics.print( self.commandsPos, 10, y+200 )
	-- Draw commands.
	for k, command in ipairs( self.commands ) do
		love.graphics.draw( self.commandImages[command], 450+(44*k)-((self.commandsPos-1)*44), y, 0, 0.65 )
	end
end

function CommandQueue:toggleRun()
	if self.state == STOPPED then
		self.commandsPos = 0
		self:play()
	else
		if self.state == PLAYING then
			self:pause()
		else
			self:play()
		end
	end
end

function CommandQueue:play()
	self.state = PLAYING
end

function CommandQueue:pause()
	self.state = PAUSED
end

function CommandQueue:stop()
	self.commandsPos = #self.commands
	self.state = STOPPED
end

function CommandQueue:next()
	self.commandsPos = self.commandsPos + 1
	if self.commandsPos > #self.commands then
		self.commandsPos = 1
	end
end

function CommandQueue:prev()
	self.commandsPos = self.commandsPos - 1
	if self.commandsPos < 1 then
		self.commandsPos = #self.commands
	end
end

function CommandQueue:runCommand()
	if self.state ~= PLAYING then return end
	
	-- Clear the waiting queue if the waiting queue is full.
	if #waitingQueue >= 2 then 
		waitingQueue = {}
		if self.commandingWaldo == WALDO_GREEN then return end
	end
	-- Return if we're on the waiting queue.
	for k, v in pairs( waitingQueue ) do
		if v == self then return end
	end
	
	-- Move command pos on.
	self:next()
	
	local command = self.commands[ self.commandsPos ]
	local waldo	  = self.commandingWaldo
	
	-- Tell each object to perform a tick.
	for k, v in ipairs( Objects ) do v:tick() end
	
	if command == nil then return end
	
	if command == CMD_ROTATE_CW then
		waldos[waldo]:rotateArm( 0 )
	elseif command == CMD_ROTATE_CCW	then
		waldos[waldo]:rotateArm( 1 )
	elseif command == CMD_GRABDROP then
		waldos[waldo]:grabDrop()
	elseif command == CMD_EXTEND then
		waldos[waldo]:extend()
	elseif command == CMD_SENSE then
		Beholder.trigger('fireSensors')
	elseif command == CMD_JUMP then
		lastWaldo = waldo
		self:jump( )
	elseif command == CMD_LOOP then
		self:loop( waldo )
	elseif command == CMD_INPUT then
		Beholder.trigger('fireInputs')
	elseif command == CMD_OUTPUT then
		Beholder.trigger('fireOutputs')
	elseif command == CMD_HORIZONTAL then
		waldos[waldo]:moveHorizontal()
	elseif command == CMD_VERTICAL then
		waldos[waldo]:moveVertical()
	elseif command == CMD_WAIT then
		table.insert( waitingQueue, self )
	end
end

function CommandQueue:sensorJump( )
	if self.commandsPos >= #self.commands then return end
	local waldo = lastWaldo
	for i = self.commandsPos+1, #self.commands do
		local command = self.commands[i]
		if command and (command == CMD_JUMP or command == CMD_SENSE) then
			self.commandsPos = i
			break
		end
	end
end

function CommandQueue:jump( )
	if self.commandsPos >= #self.commands then return end
	local waldo = lastWaldo
	for i = self.commandsPos+1, #self.commands do
		local command = self.commands[i]
		if command and command == CMD_JUMPOUT then
			self.commandsPos = i
			break
		end
	end
end

function CommandQueue:loop( waldo )
	if not self.loopPoints[ waldo ] then
		self.loopPoints[ waldo ] = self.commandsPos
	else
		self.commandsPos = self.loopPoints[ waldo ]
	end
end