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
CMD_LOOPIN		= 10
CMD_LOOPOUT		= 11
CMD_INPUT		= 12
CMD_OUTPUT		= 13
CMD_GRAB			= 14
CMD_DROP			= 15


STOPPED			= 0
PLAYING			= 1
PAUSED			= 2

function CommandQueue:initialize( waldoColor )
	self.commands = {}
	self.commandsPos = 1
	
	self.running = false
	self.state = STOPPED
	self.loopPoints = {}
	self:observe('fireSensorTrue', CommandQueue.onSensorTrue, self)
	self:observe('nextTick', CommandQueue.runCommand, self)
	self:observe('stop', CommandQueue.stop, self)
	self:observe('play', CommandQueue.play, self)
	self:observe('pause', CommandQueue.pause, self)
	self.commandingWaldo = waldoColor
	
	self:createJumpList()
end

function CommandQueue:onSensorTrue()
	if self.awaitingSensorResponse then
		self.sensorTrue = true
	end
end

function CommandQueue.loadImages()
	CommandQueue.commandImages = {}
	CommandQueue.commandImages[CMD_ROTATE_CW] = love.graphics.newImage( 'images/cw.png' )
	CommandQueue.commandImages[CMD_ROTATE_CCW] = love.graphics.newImage( 'images/ccw.png' )
	CommandQueue.commandImages[CMD_EXTEND] = love.graphics.newImage( 'images/extend.png' )
	CommandQueue.commandImages[CMD_GRABDROP] = love.graphics.newImage( 'images/grabdrop.png' )
	CommandQueue.commandImages[CMD_SENSE] = love.graphics.newImage( 'images/sense.png' )
	CommandQueue.commandImages[CMD_JUMP] = love.graphics.newImage( 'images/jump.png' )
	CommandQueue.commandImages[CMD_LOOPIN] = love.graphics.newImage( 'images/loopin.png' )
	CommandQueue.commandImages[CMD_LOOPOUT] = love.graphics.newImage( 'images/loopout.png' )
	--CommandQueue.commandImages[CMD_INPUT] 			= love.graphics.newImage( 'images/input.png' )
	--CommandQueue.commandImages[CMD_OUTPUT] 		= love.graphics.newImage( 'images/output.png' )
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
	
	self:createJumpList()
end

function CommandQueue:removeCommand( pos )
	if #self.commands <= 0 then return end
	table.remove( self.commands, self.commandsPos )
	if self.commandsPos > #self.commands then
		self.commandsPos = self.commandsPos - 1
	end
	
	self:createJumpList()
end

function CommandQueue:draw( x, y )
	local lg = love.graphics
	lg.setColor( 255, 255, 255 )
	-- Draw commands.
	
	for i, command in ipairs( self.commands ) do
		lg.setColor( waldos[self.commandingWaldo].color )
		if (i == self.commandsPos and (command == CMD_JUMPOUT or command == CMD_JUMP or command == CMD_SENSE)) or
			(self.commands[self.commandsPos] == CMD_SENSE and i == self.senseList[self.commandsPos]) or
			(self.commands[self.commandsPos] == CMD_SENSE and i == self.jumpinList[self.senseList[self.commandsPos]]) or
			(self.commands[self.commandsPos] == CMD_JUMP and i == self.jumpinList[self.commandsPos]) or
		   (self.commands[self.commandsPos] == CMD_JUMPOUT and i == self.jumpoutList[self.commandsPos]) then
				lg.setColor( 255, 255,255 )
		end
		love.graphics.draw( self.commandImages[command], 450+(44*i)-((self.commandsPos-1)*44), y, 0, 0.65 )
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
	if self.state == STOPPED then
		self.commandsPos = 0
	end
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
	
	-- Jump if sensor returned true
	if self.sensorTrue then
		self.sensorTrue = false
		self:sensorJump()
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
		if Sensor.onFireSensors() then
			self.sensorTrue = true
		end
	elseif command == CMD_JUMP then
		lastWaldo = waldo
		self:jump( )
	elseif command == CMD_LOOPIN then
		self:loopin()
	elseif command == CMD_LOOPOUT then
		self:loopout()
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

function CommandQueue:createJumpList()
	local jumpinList 	= {}
	local jumpoutList = {}
	local senseList	= {}
	local command1, command2
	local jumpref = 0
	for i1 = 1, #self.commands do
		command1 = self.commands[i1]
		if command1 == CMD_JUMP then
			jumpref = 0
			for i2 = i1+1, #self.commands do
				command2 = self.commands[i2]
				if command2 == CMD_JUMP then jumpref = jumpref + 1 end
				if jumpref == 0 and command2 == CMD_JUMPOUT and not jumpoutList[i2] then
					jumpoutList[i2] 	= i1
					jumpinList[i1]		= i2
					break
				end
				if command2 == CMD_JUMPOUT then jumpref = jumpref - 1 end
			end
		elseif command1 == CMD_SENSE then
			for i2 = i1+1, #self.commands do
				command2 = self.commands[i2]
				if command2 == CMD_JUMP then
					senseList[i1] = i2
					break
				end
			end
		end
	end
	
	self.jumpinList 	= jumpinList
	self.jumpoutList 	= jumpoutList
	self.senseList		= senseList
end

function CommandQueue:sensorJump( )
	if self.commandsPos >= #self.commands then return end
	self.commandsPos = self.senseList[self.commandsPos]
end

function CommandQueue:jump( )
	if self.commandsPos >= #self.commands then return end
	self.commandsPos = self.jumpinList[self.commandsPos]
end

function CommandQueue:loopin()
	self.loopinPoint = self.commandsPos
end

function CommandQueue:loopout()
	self.commandsPos = self.loopinPoint
end

function CommandQueue:loop( waldo )
	if not self.loopPoints[ waldo ] then
		self.loopPoints[ waldo ] = self.commandsPos
	else
		self.commandsPos = self.loopPoints[ waldo ]
	end
end