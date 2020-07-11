require "items.InputOutput"
require "items.Box"
Output = InputOutput:subclass( "Output" )

OUTPUT_BOX 		= 0
OUTPUT_PAINT 	= 1

Output.slotPosition = {}
Output.slotPosition[1]  = { x = -11, y = -11 }
Output.slotPosition[2]  = { x =  11, y = -11 }
Output.slotPosition[3]  = { x = -11, y =  11 }
Output.slotPosition[4]  = { x =  11, y =  11 }

function Output:initialize( ... )
	InputOutput.initialize( self, ... )
	self:observe( 'fireOutputs', Output.output, self )
	self.pipePaint = {}
end

function Output:setup( x, y, slot1, slot2, slot3, slot4 )
	InputOutput.setup( self, x, y, slot1, slot2, slot3, slot4 )
	
	if slot2 or slot3 or slot4 then
		self.outputType = OUTPUT_BOX
	else
		self.outputType = OUTPUT_PAINT
	end
end

function Output:tick()
	local object = self:getAnyObjectAbove()
	if object and self.outputType == OUTPUT_PAINT and not object.isGrabbed and object.class.name == "Paint" then
		self:output()
	elseif object and self.outputType == OUTPUT_BOX and not object.isGrabbed and object.class.name == "Box" then
		self:output()
	end
end

function Output:output()
	local object
	if self.outputType == OUTPUT_PAINT then
		object = self:checkForColor( self.slots[1] )
		if not object then return false end
		self.pipePaint[#self.pipePaint+1] = { x = self.pos.x, col = object.paintColor }
	elseif self.outputType == OUTPUT_BOX then
		object = self:checkForBox( self.slots )
		if not object then return false end
		self.pipePaint[#self.pipePaint+1] = { x = self.pos.x, col = PAINT_ANY }
	end
	
	if object then
	   self.delegate:outputDidOutput( self, object )
		object:destroy()
	end
	
	return true
end

function Output:update( dt )
	for i,paint in ipairs( self.pipePaint ) do
		paint.x = paint.x + dt * 10
		if paint.x > 1024 then
			table.remove( self.pipePaint, i )
		end
	end
end

function Output:draw()
	local lg = love.graphics
	
	-- Draw paint inside the pipe.
	for i, paint in ipairs( self.pipePaint ) do
		lg.setColor( Paint.colors[paint.col] )
		lg.circle( 'fill', paint.x, self.pos.y, 4 )
	end
	
	-- Draw output pipe
	lg.setColor( 255,255,255,128 )
	lg.setLineWidth( 12 )
	lg.setLineStyle( 'rough' )
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
			lg.circle( 'fill', self.pos.x + Output.slotPosition[i].x, self.pos.y + Output.slotPosition[i].y, 8 )
		end
	end
end
