
Sensor = Node:subclass('Sensor')
Sensor:include(Beholder)

DETECTS_COLOR    = 0
DETECTS_QUANTITY = 1

function Sensor:initialize()
	Node.initialize( self )
	self.static  		= false
	self.detects 		= DETECTS_COLOR
	self.detectValue  = PAINT_RED
	self:observe( 'fireSensors', Sensor.onFireSensors, self )
	table.insert( Objects, self )
end

function Sensor:setup( x, y, detects, value )
	self:setGridPos( x, y )
	self.detects = detects
	self.detectValue = value
end

function Sensor:onFireSensors()
	print('sensing')
	if self:sense() then
		print('sensor true')
		Beholder.trigger('fireSensorTrue')
	end
end

function Sensor:sense()
	for i, object in ipairs( Objects ) do
		if instanceOf( Paint, object ) and object:gridPos() == self:gridPos() then
			print('found paint object')
			-- If this is a color sensor
			if self.detects == DETECTS_COLOR and self:checkColor( object ) then
				return object
			elseif self:checkQuantity( object ) then
				return object
			end
		end
	end
	return false
end

function Sensor:checkColor( object )
	if object.paintColor == self.detectValue then
		print('correct color')
		return true
	end
	print('false color')
end

function Sensor:checkQuantity( object )
	if instanceOf( Box, object ) and object:quantity() == self.detectValue then
		return true
	end
end

function Sensor:draw()
	if self.detects == DETECTS_COLOR then
		love.graphics.setColor( Paint.colors[self.detectValue] )
		love.graphics.circle( 'line', self.pos.x, self.pos.y, 12, 50 )
	else
		if instanceOf( InputOutput, self ) then
			love.graphics.setColor( 255, 0, 255 )
		end
		love.graphics.circle( 'line', self.pos.x, self.pos.y, 12, 50 )
		love.graphics.print( self.detectValue, self.pos.x, self.pos.y )
	end
end