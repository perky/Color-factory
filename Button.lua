Button = class( "Button" )

function Button:initialize( image, x, y, id )
	self.pos = vector( x, y )
	self.image = image
	self.id = id
end

function Button:onMousePressed( x, y, button )
	if vector(self.pos.x+13,self.pos.y+13):distance( vector(x,y) ) < 13 then
		Commands:addCommand( currentWaldo, self.id )
	end
end

function Button:draw()
	love.graphics.setColor( waldos[currentWaldo].color )
	love.graphics.draw( self.image, self.pos.x, self.pos.y, 0, 0.5 )
end

