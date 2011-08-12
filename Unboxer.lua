
Unboxer = Boxer:subclass("Unboxer")

function Unboxer:initialize()
	Boxer.initialize( self )
	self.paint = nil
end

function Unboxer:onObjectDroppedAbove( object )
	if object.class.name == "Box" then
		self.box = object
	end
end

function Unboxer:createPaint( paintColor )
	self.paint = Paint:new( self.output.pos.x, self.output.pos.y )
	self.paint:setColor( paintColor )
end

function Unboxer:tick()
	-- Check box is still in input.
	if self.box and not self.box:gridPos() == self:gridPos() then
		self.box = nil
	end
	-- Check paint is still in output.
	if self.paint and not self.paint:gridPos() == self.output:gridPos() then
		self.paint = nil
	end
	-- no paint in output, take a paint tin out of box.
	if self.box and not self.paint then
		self:createPaint( self.box:remove() )
	end
end

function Unboxer:draw()
	love.graphics.setColor( 0, 255, 0 )
	love.graphics.rectangle( 'line', self.pos.x - 20, self.pos.y - 20, 40, 40 )
	love.graphics.rectangle( 'line', self.output.pos.x - 20, self.output.pos.y - 20, 40, 40 )
end