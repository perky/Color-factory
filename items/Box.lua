require "items.Paint"
Box = Paint:subclass( "Box" )

Box.slotPosition = {}
Box.slotPosition[1]  = { x = -7, y = -7 }
Box.slotPosition[2]  = { x =  7, y = -7 }
Box.slotPosition[3]  = { x = -7, y =  7 }
Box.slotPosition[4]  = { x =  7, y =  7 }

function Box:initialize( ... )
	Paint.initialize( self, ... )
	self.slots = {}
end

function Box:addPaint( paint )
	-- Check we're actually adding paint.
	if paint.class.name ~= "Paint" then return false end
	-- If box is full then return false.
	if #self.slots == 4 then return false end
	-- Add the paint tin to the box.
	self.slots[#self.slots+1] = paint.paintColor
	paint:destroy()
	return true
end

function Box:addBox( box )
	-- Check we're actually adding a box.
	if paint.class.name ~= "Box" then return false end
	-- If box is full or potentially full then return false.
	if #self.slots + #box.slots >= 4 then return false end
	-- Add the contents of the box into this box.
	for i = 1, 4 do
		self.slots[#self.slots+1] = box[i]
	end
	box:destroy()
	return true
end

-- Remove a single paint from the box.
function Box:remove()
	local paintColor = self.slots[#self.slots]
	self.slots[#self.slots] = nil
	return paintColor
end

function Box:draw()
	local lg = love.graphics
	lg.setColor( 255, 255, 255 )
	lg.rectangle( 'fill', self.pos.x - 14, self.pos.y - 14, 28, 28)
	lg.setColor( 0, 0, 0 )
	
	for i, paint in ipairs( self.slots ) do
		lg.setColor( Paint.colors[paint] )
		lg.circle( 'fill', self.pos.x + Box.slotPosition[i].x, self.pos.y + Box.slotPosition[i].y, 5, 50 )
	end
end