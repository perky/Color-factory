
Boxer = Node:subclass('Boxer')

function Boxer:initialize()
	Node.initialize( self )
	table.insert( Objects, self )
	self.output = Node()
	self.output:setGridPos( 0, 1 )
	self:addChild( self.output )
	self.box 	= nil
	self.static = true
end

function Boxer:setup( x, y )
	Node.setup( self, x, y )
	self.box = nil
end

function Boxer:onObjectDroppedAbove( object )
	if object.class.name == "Paint" then
		if not self:checkForBox() then
			self:createBox()
		end
		self.box:addPaint( object )
	elseif object.class.name == "Box" then
		if not self:checkForBox() then
			self.box = object
			object.pos = self.output.pos
		else
			self.box:addBox( object )
		end
	end
end

function Boxer:createBox()
	self.box = Box:new()
	self.box.pos = self.output.pos
end

function Boxer:checkForBox()
	for k, object in ipairs( Objects ) do
		if instanceOf( Box, object ) and object:gridPos() == self.output:gridPos() then
			self.box = object
			return true
		end
	end
	
	-- No box found.
	self.box = nil
	return false
end

function Boxer:draw()
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.rectangle( 'line', self.pos.x - 20, self.pos.y - 20, 40, 40 )
	love.graphics.rectangle( 'line', self.output.pos.x - 20, self.output.pos.y - 20, 40, 40 )
end