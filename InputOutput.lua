require "Sensor"

InputOutput = Sensor:subclass("InputOutput")
InputOutput:include(Beholder)

InputOutput.image = love.graphics.newImage('images/objects/inputoutput-object.png')

IO_OUT = 0
IO_IN	 = 1

function InputOutput:initialize()
	Node.initialize( self )
	self.static = true
	self.ioColor = PAINT_RED
	self:observe( 'fireInputs', InputOutput.input, self )
	self:observe( 'fireOutputs', InputOutput.output, self )
	table.insert( Objects, self )
	self.outlist = { PAINT_YELLOW, PAINT_RED }
	self.outlistCurrent = 1
end

function InputOutput:input()
	if self.ioType == IO_OUT then return end
	local newPaint = Paint:new( self.pos.x, self.pos.y )
	
	newPaint:setColor( self.outlist[self.outlistCurrent] )
	self.outlistCurrent = (self.outlistCurrent % #self.outlist) + 1
end

function InputOutput:output()
	if self.ioType == IO_IN then return end
	local detectedObject = self:sense()
	if detectedObject then
		detectedObject:destroy()
	end
end

function InputOutput:setup( x, y, ioType, detects, detectValue )
	self:setGridPos( x, y )
	self.ioType 	= ioType
	self.detects	= detects or DETECTS_COLOR
	self.detectValue = detectValue or PAINT_RED
end

function InputOutput:draw()
	love.graphics.setColor( 255,255,255,128 )
	love.graphics.setLine( 12, 'rough' )
	if self.ioType == IO_IN then
		love.graphics.line( 0, self.pos.y, self.pos.x, self.pos.y )
	elseif self.ioType == IO_OUT then
		love.graphics.line( self.pos.x, self.pos.y, 1024, self.pos.y )
	end
	
	love.graphics.setColor( Paint.colors[self.detectValue] )
	love.graphics.draw( self.image, self.pos.x -25, self.pos.y -25 )
end