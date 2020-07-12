MenuButton = class( "MenuButton" )

BUTTON_MOUSE_OFF		= 0
BUTTON_MOUSE_OVER		= 1
BUTTON_MOUSE_PRESSED	= 2

function MenuButton:initialize( x, y, title, callback, ... )
	self.pos = vector( x, y )
	self.title = title
	self.callback = callback
	self.callbackArgs = {...}
	self.w = 300
	self.h = 22
	self.state = BUTTON_MOUSE_OFF
end

function MenuButton:update( dt )
	local mx, my = love.mouse.getX(), love.mouse.getY()
	self.state = BUTTON_MOUSE_OFF
	if mx > self.pos.x and mx < self.pos.x+self.w and my > self.pos.y and my < self.pos.y+self.h then
		if love.mouse.isDown( 1 ) then
			self.state = BUTTON_MOUSE_PRESSED
		else
			self.state = BUTTON_MOUSE_OVER
		end
	end
end

function MenuButton:mousereleased( x, y, key )
	if self.state == BUTTON_MOUSE_OVER or self.state == BUTTON_MOUSE_PRESSED then
		self.callback( unpack( self.callbackArgs ) )
	end
end

function MenuButton:draw( x, y )
	local lg = love.graphics
	if self.state == BUTTON_MOUSE_OVER then
		lg.setColor( 210/255, 255/255, 210/255 )
	else
		lg.setColor( 210/255, 210/255, 210/255 )
	end
	lg.rectangle( 'fill', x, y, self.w, self.h )
	
	lg.setColor( 0, 0, 0, 255/255 )
	lg.print( self.title, x+5, y+4 )
end
