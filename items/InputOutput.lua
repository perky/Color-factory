require "items.Sensor"

InputOutput = Sensor:subclass("InputOutput")
InputOutput:include(Beholder)

InputOutput.image = love.graphics.newImage('images/objects/inputoutput-object.png')

function InputOutput:initialize( ... )
	Node.initialize( self, ... )
	self.slots 	= {}
	self.static = true
	table.insert( Objects, self )
end

function InputOutput:output()
	if self.ioType == IO_IN then return end
	local detectedObject = self:sense()
	if detectedObject then
		detectedObject:destroy()
	end
end

function InputOutput:setup( x, y, slot1, slot2, slot3, slot4 )
	self:setGridPos( x, y )
	self.slots[1] = slot1
	self.slots[2] = slot2
	self.slots[3] = slot3
	self.slots[4] = slot4
end

function InputOutput:draw()
	local lg = love.graphics
	lg.setColor( 255,255,255,128 )
	lg.setLine( 12, 'rough' )
	if self.ioType == IO_IN then
		love.graphics.line( 0, self.pos.y, self.pos.x, self.pos.y )
	elseif self.ioType == IO_OUT then
		love.graphics.line( self.pos.x, self.pos.y, 1024, self.pos.y )
	end
	
	lg.setColor( 255,255,255,255 )
	lg.draw( self.image, self.pos.x -25, self.pos.y -25 )
	
	local c = Paint.colors[self.detectValue]
	love.graphics.setColor( c[1], c[2], c[3], 128 )
	self.arc1:drawDegrees(0,180)
	love.graphics.setColor( c[1], c[2], 255, 128 )
	self.arc2:drawDegrees(180,360)
end