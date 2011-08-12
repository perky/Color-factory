Conveyor = Node:subclass( 'Conveyor' )

CONVEYOR_HORIZONTAL 	= 1
CONVEYOR_VERTICAL		= 2

CONVEYOR_DEFAULT_LENGTH = 5

function Conveyor:initialize( x, y )
	Node.initialize( self, x, y )
	x = x or 0
	y = y or 0
	self.startPoint = self.pos
	self.endPoint   = Node()
	self:addChild( self.endPoint )
	self.visualIndicator = vector( x, y )
	self.alpha = 0
	
	self:setup( CONVEYOR_HORIZONTAL, self.pos )
	table.insert( Objects, self )
	table.insert( Objects, self.endPoint )
end

function Conveyor:setup( direction, pos )
	self.pos = pos
	self.startPoint = self.pos
	self.direction = direction
	if direction == CONVEYOR_HORIZONTAL then
		self.endPoint.pos = vector( pos.x + TILE_SIZE * CONVEYOR_DEFAULT_LENGTH, pos.y )
	else
		self.endPoint.pos = vector( pos.x, pos.y + TILE_SIZE * CONVEYOR_DEFAULT_LENGTH )
	end
	self:savePos()	
end

function Conveyor:tick()
	local direction = self.endPoint.pos - self.pos
	direction:normalize_inplace()
	
	local scanPos = vector( self.pos.x, self.pos.y )
	while scanPos ~= self.endPoint.pos do
		for k, object in ipairs( Objects ) do
			if object:gridPos() == Node.vectorToGridPos( scanPos ) and instanceOf( Paint, object ) then
				object.targetPos = scanPos + (direction * TILE_SIZE)
				object.isMoving = true
			end
		end
		
		scanPos = scanPos + ( direction * TILE_SIZE )
	end
end

function Conveyor:update( dt )
	Node.update( self, dt )
	if self.isDragging or self.endPoint.isDragging then
		self.visualIndicator = self.pos
	end
	
	local direction = self.endPoint.pos - self.pos
	direction:normalize_inplace()
	self.visualIndicator = self.visualIndicator + ( direction * TILE_SIZE * dt )
	if self.visualIndicator:distance( self.pos ) > self.pos:distance( self.endPoint.pos ) then
		self.visualIndicator = self.pos:clone()
	end
	
	local halfPoint = (self.endPoint.pos - self.pos)/2
	local distToHalfPoint = self.visualIndicator:distance( halfPoint + self.pos )
	self.alpha = 255 - (255/halfPoint:len())*distToHalfPoint
end

function Conveyor:draw()
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.line( self.pos.x, self.pos.y, self.endPoint.pos.x, self.endPoint.pos.y )
	love.graphics.circle( 'line', self.pos.x, self.pos.y, 10, 50 )
	love.graphics.circle( 'line', self.endPoint.pos.x, self.endPoint.pos.y, 10, 50 )
	love.graphics.setColor( 255, 255, 255, self.alpha )
	love.graphics.circle( 'fill', self.visualIndicator.x, self.visualIndicator.y, 4, 20 )
end