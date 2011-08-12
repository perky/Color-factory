require "Button"

CommandQueue = class("CommandQueue")
CommandQueue:include(Beholder)

CMD_ROTATE_CW	=	0
CMD_ROTATE_CCW	=	1
CMD_EXTEND		=	2
CMD_GRABDROP	=	3
CMD_GRAB			=	4
CMD_DROP			=	5
CMD_SENSE		=	6
CMD_JUMP			=	7
CMD_LOOP			=	8
CMD_INPUT		=	9
CMD_OUTPUT		= 10
CMD_HORIZONTAL = 11
CMD_VERTICAL	= 12
CMD_JUMPOUT		= 13

STOPPED			= 0
PLAYING			= 1
PAUSED			= 2

function CommandQueue:initialize( waldoColor )
	self.commands = {}
	self.commandsPos = 0
	
	self.running = false
	self.state = STOPPED
	self.loopPoints = {}
	self:observe('fireSensorTrue', CommandQueue.sensorJump, self)
	self:observe('nextTick', CommandQueue.runCommand, self)
	self.commandingWaldo = waldoColor
end

function CommandQueue.loadImages()
	CommandQueue.commandImages = {}
	CommandQueue.commandImages[0] = love.graphics.newImage( 'images/cw.png' )
	CommandQueue.commandImages[1] = love.graphics.newImage( 'images/ccw.png' )
	CommandQueue.commandImages[2] = love.graphics.newImage( 'images/extend.png' )
	CommandQueue.commandImages[3] = love.graphics.newImage( 'images/grabdrop.png' )
	CommandQueue.commandImages[6] = love.graphics.newImage( 'images/sense.png' )
	CommandQueue.commandImages[7] = love.graphics.newImage( 'images/jump.png' )
	CommandQueue.commandImages[8] = love.graphics.newImage( 'images/loop.png' )
	CommandQueue.commandImages[9] = love.graphics.newImage( 'images/input.png' )
	CommandQueue.commandImages[10] = love.graphics.newImage( 'images/output.png' )
	CommandQueue.commandImages[11] = love.graphics.newImage( 'images/horizontal.png' )
	CommandQueue.commandImages[12] = love.graphics.newImage( 'images/vertical.png' )
	CommandQueue.commandImages[13] = love.graphics.newImage( 'images/jumpout.png' )
end
CommandQueue.loadImages()

function CommandQueue:addCommand( command )
	
	table.insert(self.commands, self.commandsPos, command )
	self.commandsPos = self.commandsPos + 1
	
end

function CommandQueue:removeCommand( pos )
	self.commandsPos = self.commandsPos - 1
	table.remove( self.commands, pos or self.commandsPos )
end

function CommandQueue:draw( x, y )
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.setColor( waldos[self.commandingWaldo].color )
	love.graphics.print( self.commandsPos, 10, 200 )
	-- Draw commands.
	for k, command in pairs( self.commands ) do
		if command == CMD_INPUT or command == CMD_OUTPUT then
			love.graphics.setColor( 255, 255, 255 )
		end
		love.graphics.draw( self.commandImages[command], 420+(64*k)-((self.commandsPos-1)*64), y )
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
	self:runCommand()
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
		self.commandsPos = 0
	end
end

function CommandQueue:prev()
	self.commandsPos = self.commandsPos - 1
	if self.commandsPos < 0 then
		self.commandsPos = #self.commands
	end
end

function CommandQueue:runCommand()
	if self.state == PAUSED then return end
	
	local command = self.commands[ self.commandsPos ]
	local waldo	  = self.commandingWaldo
	
	-- Move command pos on.
	self:next()
	
	-- Tell each object to perform a tick.
	for k, v in ipairs( Objects ) do v:tick() end
	
	if command == nil then return end
	
	if command == CMD_ROTATE_CW then
		waldos[waldo]:rotateArm( 0 )
	elseif command == CMD_ROTATE_CCW	then
		waldos[waldo]:rotateArm( 1 )
	elseif command == CMD_GRABDROP then
		waldos[waldo]:grabDrop()
		self:runCommand()
	elseif command == CMD_EXTEND then
		waldos[waldo]:extend()
	elseif command == CMD_SENSE then
		lastWaldo = waldo
		Beholder.trigger('fireSensors')
		self:runCommand()
	elseif command == CMD_JUMP then
		lastWaldo = waldo
		self:jump( )
		self:runCommand()
	elseif command == CMD_LOOP then
		self:loop( waldo )
		self:runCommand()
	elseif command == CMD_INPUT then
		Beholder.trigger('fireInputs')
		self:runCommand()
	elseif command == CMD_OUTPUT then
		Beholder.trigger('fireOutputs')
		self:runCommand()
	elseif command == CMD_HORIZONTAL then
		waldos[waldo]:moveHorizontal()
	elseif command == CMD_VERTICAL then
		waldos[waldo]:moveVertical()
	end
end

function CommandQueue:sensorJump( )
	if self.commandsPos >= #self.commands then return end
	local waldo = lastWaldo
	for i = self.commandsPos+1, #self.commands do
		local command = self.commands[i]
		if command and self.commandingWaldo == waldo and (command == CMD_JUMP or command == CMD_SENSE) then
			self.commands.current = i
			break
		end
	end
end

function CommandQueue:jump( )
	if self.commandsPos >= #self.commands then return end
	local waldo = lastWaldo
	for i = self.commandsPos+1, #self.commands do
		local command = self.commands[i]
		if command and self.commandingWaldo == waldo and command == CMD_JUMPOUT then
			self.commands.current = i
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