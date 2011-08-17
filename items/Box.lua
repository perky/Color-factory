require "items.Paint"
Box = Paint:subclass( "Box" )
Box.image = love.graphics.newImage('images/objects/box.png')

Box.slotPosition = {}
Box.slotPosition[1]  = { x = -6, y = -6 }
Box.slotPosition[2]  = { x =  6, y = -6 }
Box.slotPosition[3]  = { x = -6, y =  6 }
Box.slotPosition[4]  = { x =  6, y =  6 }

function Box:initialize( ... )
	Paint.initialize( self, ... )
	self.slots = {}
end

function Box:addPaint( paintColor )
	-- If box is full then return false.
	if #self.slots == 4 then return false end
	-- Add the paint tin to the box.
	self.slots[#self.slots+1] = paintColor
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

function Box:draw( override )
   if self.isHidden and not override then return end
   
	local lg = love.graphics
	lg.setColor( 255, 255, 255, 255 )
	lg.draw( self.image, self.pos.x, self.pos.y, 0, 1, 1, 12, 12 )
	
	for i, paintColor in ipairs( self.slots ) do
		lg.setColor( 0,0,0,128)
		lg.setColor( Paint.colors[paintColor] )
		lg.circle( 'fill', self.pos.x + Box.slotPosition[i].x, self.pos.y + Box.slotPosition[i].y, 3, 50 )
	end
end