require "InputOutput"
Output = InputOutput:subclass( "Output" )

OUTPUT_BOX 		= 0
OUTPUT_PAINT 	= 1

function Output:initialize( ... )
	InputOutput.initialize( self, ... )
	self:observe( 'fireOutputs', Output.output, self )
end

function Output:setup( x, y, slot1, slot2, slot3, slot4 )
	InputOutput.setup( self, x, y, slot1, slot2, slot3, slot4 )
	
	if slot2 or slot3 or slot4 then
		self.outputType = OUTPUT_BOX
	else
		self.outputType = OUTPUT_PAINT
	end
end

function Output:output()
	
	--local detectedObject = self:sense()
	--if detectedObject then
	--	detectedObject:destroy()
	--end
end

function Output:draw()
	local lg = love.graphics
	-- Draw output pipe
	lg.setColor( 255,255,255,128 )
	lg.setLine( 12, 'rough' )
	lg.line( self.pos.x, self.pos.y, 1024, self.pos.y )
	
	
	if self.outputType == OUTPUT_PAINT then	
		-- Draw the output circle.
		lg.setColor( Paint.colors[self.slots[1]] )
		lg.draw( self.image, self.pos.x -25, self.pos.y -25 )
	else
		-- Draw the output square.
		lg.rectangle( 'fill', self.pos.x-13, self.pos.y-13, 26, 26 )
	end
end