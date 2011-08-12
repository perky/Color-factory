
Mixer = Boxer:subclass('Mixer')

function Mixer:initialize()
	Boxer.initialize( self )
	self.paint = nil
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
	if self.paint.paintColor == paint.paintColor then
		return false
	else
		local mixedColor = self.paint.paintColor + paint.paintColor
		if mixedColor > PAINT_GREEN or mixedColor == PAINT_RED or mixedColor == PAINT_YELLOW or mixedColor == PAINT_BLUE or paint.paintColor == PAINT_PURPLE then
			return false
		else
			self.paint.paintColor = mixedColor
			paint:destroy()
		end
	end
end