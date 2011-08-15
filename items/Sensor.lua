
Sensor = Node:subclass('Sensor')
Sensor:include(Beholder)
Sensor.instances = {}

Sensor.image = love.graphics.newImage("images/objects/sensor-object.png")

-- Class method.
function Sensor.onFireSensors()
	for i,v in ipairs(Sensor.instances) do
		if v:checkForColor() then
			return true
		end
	end
end

function Sensor:initialize()
	Node.initialize( self )
	self.static  		= false
	self.ungrabable = true
	table.insert( Objects, self )
	table.insert( self.instances, self )
end

function Sensor:destroy()
	for i,v in ipairs(self.instances) do
		if v == self then 
			table.remove( self.instances, i )
			break
		end
	end
	Node.destroy( self )
end

function Sensor:setup( x, y, colorToDetect )
	Node.setup( self, x, y, colorToDetect )
	self.colorToDetect = colorToDetect
end

function Sensor:checkForColor( color )
	local color = color or self.colorToDetect
	local paint = self:getObjectAbove( "Paint" )
	if paint and color == PAINT_ANY then
		return paint
	end
	if paint and paint.paintColor == color then
		return paint
	end
end

function Sensor:checkForBox( boxTable )
	local box = self:getObjectAbove( "Box" )
	if box then
		local box1 = table.copy( boxTable )
		local box2 = table.copy( box.slots )
	
		table.sort( box1 )
		table.sort( box2 )
		for i = 1, #box1 do
			if box1[i] ~= box2[i] then return false end
		end
	
		return box
	end
end

function Sensor:checkColor( object )
	if object.paintColor == self.detectValue then
		return true
	end
end

function Sensor:draw()
	local lg = love.graphics
	
	lg.setColor( Paint.colors[self.colorToDetect] )
	lg.draw( self.image, self.pos.x, self.pos.y, 0, 1, 1, 23, 23 )
end