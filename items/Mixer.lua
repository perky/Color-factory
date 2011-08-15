
Mixer = Boxer:subclass('Mixer')
Mixer.image = love.graphics.newImage( "images/objects/mixer-object.png" )

function Mixer:initialize()
	Boxer.initialize( self )
	self.paint = nil
	self.ungrabable = true
end

function Mixer:onObjectDroppedAbove( object )
	if object.class.name == "Paint" then
		if self:checkForPaint() then
			self:mix( object )
		else
			self.paint = object
			object.pos = self.output.pos
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
		local mixedColor = pc + paint.paintColor
		self.paint.paintColor = mixedColor
		paint:destroy()
	end
end

function Mixer:draw()
	local lg = love.graphics
	lg.setColor( 255, 255, 255, 255 )
	lg.draw( self.image, self.pos.x, self.pos.y, 0, 1, 1, 19, 16 )
end