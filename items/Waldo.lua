Waldo = Node:subclass("Waldo")

-- This is 1/4 of TAU per second, a quarter circle per second.
ROTATE_SPEED 	= 4
MOVE_SPEED 		= 50

function Waldo:initialize( x, y, name, id )
	Node.initialize( self, x, y, name )
	self.id			= id
	self.arm	 		= Node:new( self.pos.x + 100, y or 0 )
	self.name 		= name .. " head"
	self.arm.name  = name .. " arm"
	self:addChild( self.arm )
	self.isGrabbing 	= false
	self.rotateCount 	= 0
	self.moveCount		= 0
	self.extended 		= true
	self.horizontal	= false
	self.vertical		= false
	self.disabled		= false
	self:setZ( 1000 )
	table.insert( Objects, self )
end

function Waldo:setup( x, y, length, direction )
	self:setGridPos( x, y )
	self.basePos = self.pos:clone()
	self.extended = true
	self:drop()
	if direction == LEFT then
		self.arm:setGridPos( x - length, y )
	elseif direction == RIGHT then
		self.arm:setGridPos( x + length, y )
	elseif direction == UP then
		self.arm:setGridPos( x, y - length )
	elseif direction == DOWN then
		self.arm:setGridPos( x, y + length )
	end
	self:savePos()
end

function Waldo:savePos( ... )
	Node.savePos( self, ... )
	self.basePos = self.pos:clone()
end

function Waldo:loadPos( ... )
	Node.loadPos( self, ... )
	self.basePos		= self.pos:clone()
	self.extended 		= true
	self.horizontal 	= false
	self.vertical 		= false
	self.isGrabbing	= false
end

function Waldo:update( dt )
	if self.disabled then return end
	Node.update( self, dt )
	
	if self.isMoving then
		if dt < 0.2 then
			local dVector = ( self.targetPos2 - self.pos ):normalized() * TILE_SIZE * dt
			self:moveBy( dVector )
			self.moveCount = self.moveCount + dVector:len()
		else
			self.moveCount = TILE_SIZE
		end
		if self.moveCount >= TILE_SIZE then
			self.isMoving = false
			self.moveCount = 0
			self:moveTo( self.targetPos2 )
		end
	end
	
	if self.isExtending then
		local dVector = (self.armDirection*dt*TILE_SIZE)
		self.arm:moveBy( dVector )
		self.moveCount = self.moveCount + dVector:len()
		if self.moveCount >= TILE_SIZE then
			self.isExtending = false
			self.moveCount = 0
			self.arm.pos = self.targetPos
			self.arm:snapAllToGrid()
		end
	end

	if self.isRotating then
		-- Smoothly rotate around, depending on diretion.
		local dAngle = (TAU/ROTATE_SPEED) * dt
		if self.rotateDirection == 0 then
			self:rotateAround( self.pos, dAngle )
		else
			self:rotateAround( self.pos, -dAngle )
		end
		-- Memorise amount rotated.
		self.rotateCount = self.rotateCount + dAngle
		-- Finished rotating 90 degrees.
		if self.rotateCount >= TAU/4 then
			self.isRotating = false
			self.rotateCount = 0
			-- Move to the precalculated position to ensure we stay on grid.
			self:finishedRotating()
		end
	end
end

function Waldo:tick()
	if true then return end
	if self.isMoving then
		self.isMoving = false
	end
	if self.isExtending then
		self.isExtending = false
		self.arm.pos = self.targetPos
	end
	self.moveCount = 0
	self:snapAllToGrid()
end

function Waldo:draw()
	if self.disabled then return end
	local lg = love.graphics
	lg.setLineWidth( 1 )
	lg.setLineStyle( 'smooth' )
	
	-- Draw square base frame.
	lg.setColor( self.color[1], self.color[2], self.color[3], 32 )
	lg.rectangle( 'line', self.basePos.x - TILE_SIZE, self.basePos.y - TILE_SIZE, TILE_SIZE, TILE_SIZE )
	
	-- Draw base circle and arm line.
	lg.setColor( self.color[1], self.color[2], self.color[3], 255 )
	lg.line( self.pos.x, self.pos.y, self.arm.pos.x, self.arm.pos.y )
	lg.circle( 'fill', self.pos.x, self.pos.y, 10, 100 )
	
	if	self.isGrabbing then 
		lg.setColor( self.color[1], self.color[2], self.color[3], 80 )
		lg.circle( 'fill', self.arm.pos.x, self.arm.pos.y, 20, 100 )
	end
	lg.setColor( self.color )
	lg.circle( 'line', self.arm.pos.x, self.arm.pos.y, 20, 100 )
	
	lg.setColor( 255, 255, 255, 255 )
end

function Waldo:grabDrop()
	if self.isGrabbing then
		self:drop()
	else
		self:grab()
	end
end

function Waldo:grab()
	local paint = self:getPaintUnderArm()
	if paint then
		self.arm:addChild( paint )
		self.isGrabbing = true
		self.grabbedPaint = paint
		paint.isGrabbed = true
	end
end

function Waldo:drop()
	if #self.arm.children > 0 then	
		for k, object in ipairs( Objects ) do
			if object:gridPos() == self.arm:gridPos() and object ~= self.arm then
				object:onObjectDroppedAbove( self.arm.children[1] )
			end
		end
	end
	
	self.isGrabbing = false
	self.arm:removeAllChildren()
	if self.grabbedPaint then 
		self.grabbedPaint.isGrabbed = false
		self.grabbedPaint = nil
	end
end

function Waldo:getPaintUnderArm()
	for k, object in ipairs( Objects ) do
		if object:gridPos() == self.arm:gridPos() and object ~= self.arm and not object.ungrabable then
			object:onWaldoGrab()
			if not object.static and not self:isAncestor( object ) then
				return object
			end
		end
	end
end

function Waldo:isAncestor( object )
	local ancestors = self:getAncestors()
	for k, ancestor in ipairs( ancestors ) do
		if ancestor == object then
			return true
		end
	end
end

function Waldo:rotateArm( direction )
	self.isRotating = true
	self.rotateDirection = direction
	-- Precalculate the rotation.
	if direction == 0 then
		self:rotateAroundInGrid( self:gridPos(), TAU/4 )
	else
		self:rotateAroundInGrid( self:gridPos(), -TAU/4 )
	end
end

function Waldo:extend()
	local armDirection = self.arm:gridPos() - self:gridPos()
	armDirection:normalize_inplace()
	self.isExtending = true
	if self.extended then
		self.extended = false
		self.armDirection = -armDirection
		self.targetPos = ( self.arm:gridPos() - armDirection ) * TILE_SIZE
	else
		self.extended = true
		self.armDirection = armDirection
		self.targetPos = ( self.arm:gridPos() + armDirection ) * TILE_SIZE
	end
end

function Waldo:moveHorizontal()
	if true then
		self.isMoving = true
		if self.horizontal then
			self.targetPos2 = ( self:gridPos() - vector( -1, 0 ) ) * TILE_SIZE
		else
			self.targetPos2 = ( self:gridPos() + vector( -1, 0 ) ) * TILE_SIZE
		end
		-- toggle horizontal boolean
		self.horizontal = not self.horizontal
	end
end

function Waldo:moveVertical()
	if true then
		self.isMoving = true
		if self.vertical then
			self.targetPos2 = ( self:gridPos() - vector( 0, -1 ) ) * TILE_SIZE
		else
			self.targetPos2 = ( self:gridPos() + vector( 0, -1 ) ) * TILE_SIZE
		end
		self.vertical = not self.vertical
	end
end
