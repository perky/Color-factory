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
	self.commands = Ringbuffer()
	self.running = false
	self.state = STOPPED
	self.loopPoints = {}
	self:observe('fireSensorTrue', CommandQueue.sensorJump, self)
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

function CommandQueue:addCommand( waldo, command )
	print(waldo,command)
	table.insert(self.commands.items, self.commands.current+1, { waldo, command })
	self.commands:next()
end

function CommandQueue:removeCommand( pos )
	self.commands:prev()
	self.commands:removeAt( 1 )
end

function CommandQueue:onMousePressed( x, y, key )
	
end

function CommandQueue:draw()
	love.graphics.setColor( 255, 255, 255 )
	--love.graphics.print( "Commands: " .. currentWaldo .. " " .. self.commands:size() .. " " .. self.commands.current, 20, 8 )
	
	if self.commandingWaldo == WALDO_GREEN then
		ypos = 60
	else
		ypos = 80
	end
	love.graphics.setColor( waldos[self.commandingWaldo].color )
	for k, v in pairs( self.commands.items ) do
		
		if v[2] == CMD_INPUT or v[2] == CMD_OUTPUT then
			love.graphics.setColor( 255, 255, 255 )
		end
		love.graphics.draw( self.commandImages[v[2]], 420+(64*k)-((self.commands.current-1)*64), ypos )
	end
end

function CommandQueue:toggleRun()
	if self.state == STOPPED then
		self.commands.current = 0
		self.state = PLAYING
		self:runCommand()
	else
		if self.state == PLAYING then
			self.state = PAUSED
		else
			self.state = PLAYING
			self:runCommand()
		end
	end
end

function CommandQueue:runCommand()
	if self.state == PAUSED then return end
	
	local commandTable = self.commands:next()
	for k, v in ipairs( Objects ) do v:tick() end
	
	if commandTable == nil then
		return
	end
	
	local waldo			 = self.commandingWaldo
	local command		 = commandTable[2]
	
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
	if self.commands.current >= self.commands:size() then return end
	local waldo = lastWaldo
	for i = self.commands.current+1, self.commands:size() do
		local command = self.commands.items[i]
		if command and command[1] == waldo and (command[2] == CMD_JUMP or command[2] == CMD_SENSE) then
			self.commands.current = i
			break
		end
	end
end

function CommandQueue:jump( )
	if self.commands.current >= self.commands:size() then return end
	local waldo = lastWaldo
	for i = self.commands.current+1, self.commands:size() do
		local command = self.commands.items[i]
		if command and command[1] == waldo and command[2] == CMD_JUMPOUT then
			self.commands.current = i
			break
		end
	end
end

function CommandQueue:loop( waldo )
	if not self.loopPoints[ waldo ] then
		self.loopPoints[ waldo ] = self.commands.current
	else
		self.commands.current = self.loopPoints[ waldo ]
	end
end