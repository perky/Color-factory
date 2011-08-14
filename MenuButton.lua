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
	if mx > self.pos.x and mx < self.pos.x+self.w and my > self.pos.y and my < self.pos.y+self.h then
		if love.mouse.isDown() then
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

function MenuButton:draw()
	local lg = love.graphics
	lg.setColor( 210, 210, 210 )
	lg.rectangle( 'fill', self.pos.x, self.pos.y, self.w, self.h )
	
	lg.setColor( 0, 0, 0 )
	lg.print( self.title, self.pos.x+5, self.pos.y+4 )
end