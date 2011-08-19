Button = class( "Button" )
Button.instances = {}

function Button:initialize( image, x, y, color, scale, callback, ... )
	self.pos = vector( x, y )
	self.image = image
	self.callback = callback
	self.callbackArgs = {...}
	self.color = color
	self.scale = scale
	table.insert( self.instances, self )
	return self
end

function Button:destroy()
   for k, v in pairs( self.instances ) do
      if v == self then
         table.remove( self.instances, k )
         break
      end
   end
   self = nil
end

function Button:apply( method, ... )
	for i,v in ipairs(Button.instances) do
		v[method]( v, ... )
	end
end

function Button.runCommand( id )
	commandQueue[currentWaldo]:addCommand( id )
end

function Button.createCommands( list )
	-- Create buttons.
	local n = 0
	for i = 0, #CommandQueue.commandImages do
		if CommandQueue.commandImages[i] and Button.findInList( list, i ) then
			local button = Button:new( CommandQueue.commandImages[i], 15+n*34, 12, nil, 0.5, Button.runCommand, i )
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

function Button:onMousePressed( x, y, button )
   local r = (54 * self.scale)/2
	if vector(self.pos.x+r,self.pos.y+r):distance( vector(x,y) ) < r then
		self.callback( unpack(self.callbackArgs) )
	end
end

function Button:draw()
	local color = self.color or waldos[currentWaldo].color
	love.graphics.setColor( color )
	love.graphics.draw( self.image, self.pos.x, self.pos.y, 0, self.scale )
end

