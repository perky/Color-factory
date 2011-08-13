Button = class( "Button" )

function Button.create( list )
	-- Create buttons.
	commandButtons = {}
	local n = 0
	for i = 0, #CommandQueue.commandImages do
		if CommandQueue.commandImages[i] and Button.findInList( list, i ) then
			local button = Button:new( CommandQueue.commandImages[i], 15+n*34, 12, i )
			table.insert(commandButtons, button)
			n = n + 1
		end
	end
end

function Button.findInList( list, command )
	if not list then return true end
	for k, v in pairs( list ) do
		if v == command then return true end
	end
end

function Button:initialize( image, x, y, id )
	self.pos = vector( x, y )
	self.image = image
	self.id = id
end

function Button:onMousePressed( x, y, button )
	if vector(self.pos.x+13,self.pos.y+13):distance( vector(x,y) ) < 13 then
		commandQueue[currentWaldo]:addCommand( self.id )
	end
end

function Button:draw()
	love.graphics.setColor( waldos[currentWaldo].color )
	love.graphics.draw( self.image, self.pos.x, self.pos.y, 0, 0.5 )
end

