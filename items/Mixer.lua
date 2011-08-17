
Mixer = Boxer:subclass('Mixer')
Mixer.backimage = love.graphics.newImage( "images/objects/mixer-back.png" )
Mixer.anim_strip = love.graphics.newImage( "images/objects/mixer-anim.png" )
Mixer.mouldanim_strip = love.graphics.newImage( "images/objects/mixer-mouldanim.png" )
Mixer.animnomould_strip = love.graphics.newImage( "images/objects/mixer-animwithoutmould.png" )

function Mixer:initialize()
	Boxer.initialize( self )
	self.paint = nil
	self.ungrabable = true
	self.paintColor1 = PAINT_ANY
	self.paintColor2 = PAINT_ANY
	self.animState = 1
	
	self.anim1 = newAnimation( self.anim_strip, 64, 128, 1/12, 12 )
	self.anim2 = newAnimation( self.mouldanim_strip, 64, 128, 1/12, 12 )
	self.anim3 = newAnimation( self.animnomould_strip, 64, 128, 1/12, 12 )
	self.anim1:setMode('once')
	self.anim2:setMode('once')
	self.anim3:setMode('once')
	self.anim1:stop()
	self.anim2:stop()
	self.anim3:stop()
end

function Mixer:update( dt )
   Node.update( self, dt )
   self.anim1:update( dt )
   self.anim2:update( dt )
   self.anim3:update( dt )
end

function Mixer:reset()
   self.animState = 1
   if self.paint then
      self.paint:destroy()
      self.paint = nil
   end
end

function Mixer:onObjectDroppedAbove( object )
	if object.class.name == "Paint" then
		if self:checkForPaint() then
		   self:mix( object )
		else
			self.paint = object
			object.isHidden = true
			object:setGridPos( self.output:gridPos().x, self.output:gridPos().y )
			Timer.add( 1, function() self.animState = 2 end )
			
			-- Animation stuff.
			self.anim1:play()
			self.paintColor1 = object.paintColor
		end
	end
end

function Mixer:checkForPaint()
	for k, object in ipairs( Objects ) do
		if instanceOf( Paint, object ) and object:gridPos() == self.output:gridPos() then
			return true
		end
	end
	
	-- No box found.
	self.paint = nil
	return false
end

function Mixer:mix( paint )
	local pc = self.paint.paintColor
	if pc == paint.paintColor or pc == PAINT_GREEN or pc == PAINT_ORANGE or pc == PAINT_PURPLE then
		return false
	else
	   paint.isHidden = true
	   self.animState = 3
	   self.anim2:play()
	   self.anim3:play()
	   self.paintColor2 = paint.paintColor
		local mixedColor = pc + paint.paintColor
		self.mixColor = mixedColor
		Timer.add( 1, function() 
		   self.paint.paintColor = mixedColor
		   self.paint.isHidden = false
		   self.animState = 1
		end )
		
		paint:destroy()
	end
end

function Mixer:draw()
	local lg = love.graphics
	lg.setColor( 255, 255, 255, 255 )
	lg.draw( self.backimage, self.pos.x, self.pos.y, 0, 1, 1, 32, 32 )
	
	if self.animState == 1 then
	   lg.setColor( Paint.colors[self.paintColor1] )
	   self.anim1:draw( self.pos.x, self.pos.y, 0, 1, 1, 32, 32 )
	elseif self.animState >= 2 then
	   lg.setColor( Paint.colors[self.paintColor2] )
	   self.anim3:draw( self.pos.x, self.pos.y, 0, 1, 1, 32, 32 )
	   
	   lg.setColor( Paint.colors[self.paintColor1] )
	   self.anim2:draw( self.pos.x, self.pos.y, 0, 1, 1, 32, 32 )
	   if self.animState == 3 then
   	   local c = Paint.colors[self.mixColor]
   	   lg.setColor( c[1], c[2], c[3], (255/12)*(self.anim2.position-1) )
   	   self.anim2:draw( self.pos.x, self.pos.y, 0, 1, 1, 32, 32 )
   	end
	end
end