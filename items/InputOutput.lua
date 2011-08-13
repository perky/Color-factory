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