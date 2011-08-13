require "items.InputOutput"
require "items.Box"
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
	if self.outputType == OUTPUT_PAINT then
		local paint = self:checkForColor( self.slots[1] )
		if paint then
			paint:destroy()
			stateLevel:onOutputSuccesfull()
		end
	elseif self.outputType == OUTPUT_BOX then
	end
end

function Output:draw()
	local lg = love.graphics
	-- Draw output pipe
	lg.setColor( 255,255,255,128 )
	lg.setLine( 12, 'rough' )
	lg.line( self.pos.x, self.pos.y, 1024, self.pos.y )
	
	love.graphics.setColor( 0,0,0,255 )
	if self.outputType == OUTPUT_PAINT then	
		-- Draw the output circle.
		lg.setColor( Paint.colors[self.slots[1]] )
		lg.draw( self.image, self.pos.x -25, self.pos.y -25 )
	else
		-- Draw the output square.
		love.graphics.setColor( 200,200,200,255 )
		lg.rectangle( 'fill', self.pos.x-23, self.pos.y-23, 46, 46 )
		for i, paint in ipairs( self.slots ) do
			lg.setColor( Paint.colors[paint] )
			lg.circle( 'fill', self.pos.x + Box.slotPosition[i].x, self.pos.y + Box.slotPosition[i].y, 8 )
		end
	end
end