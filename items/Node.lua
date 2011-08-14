
Node = class("Node")
Node:include(Branchy)
Node:include(Callbacks)
Node:after( 'setup', 'savePos' )

Node.dragging = false
Node.zSlot = 0

function Node:initialize( x, y )
	self.pos 	= vector( x or 0, y or 0 )
	self.z = 0
	self.savedPos = self.pos
	self.color 	= { 255, 255, 255, 255 }
	self:findZSlot()
end

function Node:findZSlot()
	self.z = Node.zSlot
	Node.zSlot = Node.zSlot + 1
end

function Node:setZ( z )
	self.z = z
	Node.zSlot = Node.zSlot - 1
end

function Node:setup( x, y )
	self:setGridPos( x, y )
end

function Node:destroy()
	for i,v in ipairs( Objects ) do
		if v == self then
			table.remove( Objects, i )
		end
	end
	self = nil
end

function Node:update( dt )
	if self.isDragging then
		local target = Node.pixelPosToGridPos( vector( love.mouse.getX(), love.mouse.getY() ) )
		self:moveTo( target )
	end
end
function Node:draw() end
function Node:onObjectDroppedAbove( object ) end
function Node:onWaldoGrab() end
function Node:tick() end

function Node:savePos()
	print(self:gridPos()-vector(0,2))
	self.savedPos = self.pos
	for k, child in ipairs( self.children ) do
		child:savePos()
	end
end

function Node:loadPos()
	self.pos = self.savedPos
	for k, child in ipairs( self.children ) do
		child:loadPos()
	end
end

function Node:getObjectAbove( classname )
	for i, object in ipairs( Objects ) do
		if object and object.class.name == classname and object:gridPos() == self:gridPos() and object ~= self then
			return object
		end
	end
end

function Node:getAnyObjectAbove( )
	for i, object in ipairs( Objects ) do
		if object and object:gridPos() == self:gridPos() and object ~= self then
			return object
		end
	end
end

function Node:mousepressed( x, y, key )
	local mousePos = Node.pixelPosToGridPos( vector( x, y ) )
	if not self.static and not Node.dragging and self:pixelPos() == mousePos then
		self.isDragging = true
		Node.dragging = true
	end
end

function Node:mousereleased( x, y, key )
	Node.dragging = false
	if self.isDragging then
		self.isDragging = false
		self:savePos()
	end
end

function Node:setColor( r, g, b )
	self.color[1] = r
	self.color[2] = g
	self.color[3] = b
end

function Node:updateParentOffset()
	local offset = (self.pos - self.parent.pos) - self.lastParentOffset
	self.pos = self.pos - offset
end

function Node:moveTo( target )
	local offset = target - self.pos
	self.pos = target
	for k, child in ipairs( self.children ) do
		child:moveBy( offset )
	end
end

function Node:moveBy( vector )
	self.pos = self.pos + vector
	for k, child in ipairs( self.children ) do
		child:moveBy( vector )
	end
end

function Node:rotateAround( centerPos, angle )
	-- Rotate the vector around the center vector about the angle.
	self.pos = self.pos:rotateAround( centerPos, angle )
	-- Recurse into children.
	for k, child in ipairs( self.children ) do
		child:rotateAround( centerPos, angle )
	end
end

function Node:rotateAroundInGrid( centerPos, angle )
	local rotatedGridPos = self:gridPos():rotateAround( centerPos, angle )
	self.rotationEnd = rotatedGridPos * TILE_SIZE
	
	for i,child in ipairs( self.children ) do
		child:rotateAroundInGrid( centerPos, angle )
	end
end

function Node:finishedRotating()
	self.pos = self.rotationEnd
	for i, child in ipairs( self.children ) do
		child:finishedRotating()
	end
end

function Node:setGridPosWithVector( vector )
	self.pos = vector * TILE_SIZE
end

function Node:setPos( x, y )
	if x == "number" then
		self.pos = vector( x, y )
	else
		self.pos = x
	end
end

function Node:setGridPos( x, y )
	self:moveTo( vector( x * TILE_SIZE, y * TILE_SIZE ) )
end

function Node.pixelPosToGridPos( pixelPos )
	local gridPos = vector()
	gridPos.x = math.floor( ( pixelPos.x + TILE_SIZE/2 ) / TILE_SIZE ) * TILE_SIZE
	gridPos.y = math.floor( ( pixelPos.y + TILE_SIZE/2 ) / TILE_SIZE ) * TILE_SIZE
	return gridPos
end

function Node.vectorToGridPos( vector )
	return vector / TILE_SIZE
end

function Node:pixelPos()
	local pos = vector()
	pos.x = math.floor( ( self.pos.x + TILE_SIZE/2 ) / TILE_SIZE ) * TILE_SIZE
	pos.y = math.floor( ( self.pos.y + TILE_SIZE/2 ) / TILE_SIZE ) * TILE_SIZE
	return pos
end

function Node:gridPos()
	return self.pos / TILE_SIZE
end

function Node:snapToGrid()
	self.pos = self:pixelPos()
end

function Node:snapAllToGrid()
	self:snapToGrid()
	for k, child in ipairs( self.children ) do
		child:snapAllToGrid()
	end
end