
Box = class( 'Box', Paint )

Box.slotPosition = {}
Box.slotPosition[1] = { x = -10, y = -10 }
Box.slotPosition[2]  = { x = 10, y = -10 }
Box.slotPosition[3]  = { x = -10, y = 10 }
Box.slotPosition[4]  = { x = 10, y = 10 }

function Box:initialize()
	Paint.initialize( self )
	self.slots = {}
end

function Box:addPaint( paint, quantity )
	for i = 1, 4 do
		if self.slots[i] == nil then
			self.slots[i] = { (quantity or 1), paint.paintColor }
			paint:destroy()
			return true
		elseif self.slots[i][2] == paint.paintColor then
			self.slots[i][1] = self.slots[i][1] + (quantity or 1)
			paint:destroy()
			return true
		end
	end
end

function Box:addBox( box )
	for i = 1, 4 do
		if box.slots[i] then
			if self:addPaint( Paint:new():setColor( box.slots[i][2] ), box.slots[i][1] ) then
				box.slots[i] = nil
			end
		end
	end
	
	if box:quantity() == 0 then
		box:destroy()
	end
end

function Box:remove()
	for i = 4, 1, -1 do
		if self.slots[i] then
			local paintColor = self.slots[i][2]
			self.slots[i][1] = self.slots[i][1] - 1
			if self.slots[i][1] == 0 then
				self.slots[i] = nil
			end
			return paintColor
		end
	end
end

function Box:quantity()
	local quantity = 0
	for i = 1, 4 do
		if self.slots[i] then
			quantity = quantity + self.slots[i][1]
		end
	end
	return quantity
end

function Box:draw()
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.rectangle( 'fill', self.pos.x - 20, self.pos.y - 20, 40, 40)
	love.graphics.setColor( 0, 0, 0 )
	
	for i = 1, 4 do
		if self.slots[i] then
			love.graphics.setColor( Paint.colors[self.slots[i][2]] )
			love.graphics.circle( 'fill', self.pos.x + Box.slotPosition[i].x, self.pos.y + Box.slotPosition[i].y, 5, 50)
			love.graphics.setColor( 0, 0, 0 )
			love.graphics.print( self.slots[i][1], self.pos.x + Box.slotPosition[i].x, self.pos.y + Box.slotPosition[i].y )
		end
	end
end