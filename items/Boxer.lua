
Boxer = Node:subclass('Boxer')
Boxer.backimage = love.graphics.newImage( "images/objects/boxer-background.png" )
Boxer.animstrip = love.graphics.newImage( "images/objects/boxer-anim.png" )

function Boxer:initialize()
	Node.initialize( self )
	table.insert( Objects, self )
	self.output = Node()
	self.output:setGridPos( 0, 1 )
	self:addChild( self.output )
	self.box 	= nil
	self.static = false
	self.ungrabable = true
	self.isBoxVisible = false
	self.lastPaintColor = PAINT_ANY
	
	self.animation = newAnimation( self.animstrip, 64, 128, 1/36, 36 )
	self.animation:stop()
	self.animation:setMode('once')
end

function Boxer:setup( x, y )
	Node.setup( self, x, y )
	self.box = nil
end

function Boxer:reset()
   if self.box then
      self.box:destroy()
      self.box = nil
   end
end

function Boxer:update( dt )
   self.animation:update( dt )
end

function Boxer:onObjectDroppedAbove( object )
   if self.box and #self.box.slots >= 4 then return false end
   
	if object.class.name == "Paint" then
		self.animation:play()
		local paintColor = object.paintColor
		self.lastPaintColor = paintColor
		object:destroy()
		Timer.add( 0.5, function() 
		   if not self:checkForBox() then
   			self:createBox()
   			self.box.isHidden = true
   		end
   		self.box:addPaint( paintColor ) 
		end )
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
	local lg = love.graphics
	lg.setColor( 255, 255, 255, 255 )
	lg.draw( self.backimage, self.pos.x, self.pos.y, 0, 1, 1, 32, 32 )
	
	if self.box then self.box:draw( true ) end
	
	lg.setColor( Paint.colors[self.lastPaintColor] )
	self.animation:draw( self.pos.x, self.pos.y, 0, 1, 1, 32, 32 )
	--lg.draw( self.image, self.pos.x, self.pos.y, 0, 1, 1, 22, 16 )
	--lg.setLine( 1 )
	--lg.rectangle( 'line', self.pos.x - 20, self.pos.y - 20, 40, 40 )
	--lg.rectangle( 'line', self.output.pos.x - 20, self.output.pos.y - 20, 40, 40 )
end