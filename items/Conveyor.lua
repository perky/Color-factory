Conveyor = Node:subclass( 'Conveyor' )

CONVEYOR_HORIZONTAL 	= 1
CONVEYOR_VERTICAL		= 2

CONVEYOR_DEFAULT_LENGTH = 5

function Conveyor:initialize()
	Node.initialize( self )
	self.endPoint   = Node()
	self:addChild( self.endPoint )
	self.visualIndicator = self.pos:clone()
	self.alpha = 0
	self.z = 2
	self.ungrabable = true
	self.endPoint.ungrabable = true
	
	-- Override grab function. Remeber position and snap back if it's neither horizontal or vertical.
	self.endPoint.mousepressed = function( self, x, y, key )
		self.lastPos = self.pos
		Node.mousepressed( self, x, y, key)
	end
	
	self.endPoint.mousereleased = function( self, x, y, key )
		Node.mousereleased( self, x, y, key)
		local endPos = self.pos + self.parent.directionVec*TILE_SIZE
		if endPos ~= Node.pixelPosToGridPos( endPos ) then
			self.pos = self.lastPos
			self:savePos()
		end
	end
	
	table.insert( Objects, self )
	table.insert( Objects, self.endPoint )
end

function Conveyor:setup( x, y, direction )
	Node.setup( self, x, y, direction )
	self.endPoint.idString = self.idString .. "end"

	self.direction = direction
	if direction == CONVEYOR_HORIZONTAL then
		self.endPoint.pos = vector( self.pos.x + TILE_SIZE * CONVEYOR_DEFAULT_LENGTH, self.pos.y )
	else
		self.endPoint.pos = vector( self.pos.x, self.pos.y + TILE_SIZE * CONVEYOR_DEFAULT_LENGTH )
	end
	self:savePos()
end

function Conveyor:getDirectionVec( lazy )
	self.directionVec = self.endPoint.pos - self.pos
	self.directionVec:normalize_inplace()
	return self.directionVec
end

function Conveyor:tick()
	local scanPos = self.pos - self.directionVec*TILE_SIZE
	local endPos  = self.endPoint.pos + self.directionVec*TILE_SIZE
	while scanPos ~= endPos do
		for k, object in ipairs( Objects ) do
			if object:gridPos() == Node.vectorToGridPos( scanPos ) and instanceOf( Paint, object ) and not object.isGrabbed then
				object.targetPos = scanPos + (self.directionVec * TILE_SIZE)
				object.isMoving = true
			end
		end
		
		scanPos = scanPos + ( self.directionVec * TILE_SIZE )
	end
end

function Conveyor:update( dt )
	Node.update( self, dt )
	self:getDirectionVec( )
	local startPos = self.pos - self.directionVec*TILE_SIZE
	local endPos  	= self.endPoint.pos + self.directionVec*TILE_SIZE
	if self.isDragging or self.endPoint.isDragging then
		self.visualIndicator = startPos
	end
	
	self.visualIndicator = self.visualIndicator + ( self.directionVec * TILE_SIZE * dt )
	if self.visualIndicator:distance( self.pos ) > self.pos:distance( endPos ) then
		self.visualIndicator = startPos:clone()
	end
	
	local halfPoint = (endPos - startPos)/2
	local distToHalfPoint = self.visualIndicator:distance( halfPoint + startPos )
	self.alpha = 255 - (255/halfPoint:len())*distToHalfPoint
end

function Conveyor:draw()
	local lg = love.graphics
	local startPos = self.pos - self.directionVec*TILE_SIZE
	local endPos   = self.endPoint.pos + self.directionVec*TILE_SIZE
	
	lg.setColor( 255, 255, 255 )
	lg.setLine( 1, 'rough' )
	lg.line( startPos.x, startPos.y, endPos.x, endPos.y )
	lg.circle( 'line', self.pos.x, self.pos.y, 10, 50 )
	lg.circle( 'line', self.endPoint.pos.x, self.endPoint.pos.y, 10, 50 )
	lg.setColor( 255, 255, 255, self.alpha )
	lg.circle( 'fill', self.visualIndicator.x, self.visualIndicator.y, 4, 20 )
end