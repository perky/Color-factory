require "items.InputOutput"
Input = InputOutput:subclass( "Input" )

function Input:initialize( ... )
	InputOutput.initialize( self, ... )
	self.slots = {
		PAINT_RED,
		PAINT_RED,
		PAINT_RED,
		PAINT_RED
	}
	self:generateArcs()
	self:observe( 'fireInputs', Input.input, self )
	self:observe( 'resetInputs', Input.generateInputStack, self )
	self.inputCount = 0
end

function Input:generateArcs()
	local arcs = {}
	local arcConfig = {
		x = self.pos.x,
		y = self.pos.y,
		innerRadius = 0,
		outerRadius = 22,
		segments = 64
	}
	local angle1, angle2 = 0, 90
	for i = 1, 4 do 
		arcs[i] = Arc.create( arcConfig )
		arcs[i].angle1 = angle1
		arcs[i].angle2 = angle2
		angle1 = angle1 + 90
		angle2 = angle2 + 90
	end
	self.arcs = arcs
end

function Input:setup( x, y, slot1, slot2, slot3, slot4 )
	InputOutput.setup( self, x, y, slot1, slot2, slot3, slot4 )
	
	self:generateInputStack()
	for i = 1, 4 do self.arcs[i]:setPosition( self.pos.x, self.pos.y ) end
end

function Input:tick()
	if not self:getObjectAbove( "Paint" ) then
		self:input()
	end
end

function Input:generateInputStack()
	self.inputStack = table.copy( self.slots )
	table.shuffle( self.inputStack )
	
	-- Stock up the stack 10 more times.
	local tmp = table.copy( self.inputStack )
	for i = 1, 10 do
		table.shuffle( tmp )
		for ii = 1, #self.slots do
			self.inputStack[#self.inputStack+1] = tmp[ii]
		end
	end
end

function Input:restockInputStack()
	local tmp = table.copy( self.slots )
	table.shuffle( tmp )
	for i = 1, #self.slots do
		self.inputStack[#self.inputStack+1] = tmp[i]
	end
end

function Input:input()
	-- If inputStack is running low then restock with more paint.
	if self.inputCount == #self.slots then
		self:restockInputStack()
		self.inputCount = 0
	end
	-- Pop the paint color from the inputStack.
	local paintColor = self.inputStack[1]
	table.remove( self.inputStack, 1 )
	-- Create the new paint tin.
	local newPaint = Paint:new( self.pos.x, self.pos.y )
	newPaint:setColor( paintColor )
	-- Increment the input count.
	self.inputCount = self.inputCount + 1
end

function Input:draw()
	local lg = love.graphics
	lg.setColor( 255,255,255,255 )
	
	-- Draw the paints in the pipe.
	if self.inputStack then
		for i = 1, #self.inputStack do
			lg.setColor( Paint.colors[self.inputStack[i]] )
			lg.circle( 'fill', self.pos.x - 30 - ((i-1)*10), self.pos.y, 4 )
		end
	end
	
	-- Draw pipe running from left of screen.
	lg.setLineWidth( 12 )
	lg.setLineStyle( 'rough' )
	lg.setColor( 255, 255, 255, 128 )
	lg.line( 0, self.pos.y, self.pos.x, self.pos.y )
	
	-- Draw the input circle.
	lg.setColor( 255,255,255,255 )
	lg.draw( self.image, self.pos.x -25, self.pos.y -25 )
	
	-- Draw the input circle segments.
	lg.setColor( 255,255,255,100 )
	for i = 1, #self.slots do
		local color = Paint.colors[self.slots[i]]
		lg.setColor( color[1], color[2], color[3], 128 )
		self.arcs[i]:drawDegrees( self.arcs[i].angle1, self.arcs[i].angle2 )
	end
end
