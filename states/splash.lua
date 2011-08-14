local splash = Gamestate.new()

function splash:init()
	font_secretcode_92 = love.graphics.newFont( 'fonts/SECRCODE.TTF', 92 )
end

function splash:enter( previous )
	splash_song:play()
	
	self.title = { y = 768/2, r = 0, g = 0, b = 0, a = 255 }
	self.back  = { r = 255, g = 255, b = 255 }
	self.author = { x = 100, y = 0, r = 255, g = 0, b = 0, a = 0 }
	self.company = { x = 140, y = 300 , r = 255, g = 0, b = 255, a = 0 }
	Tween( 13.7, self.back, { r = 30, g = 30, b = 30 }, 'inCubic', Gamestate.switch, stateMenu )
	Timer.add( 1, self.tweenTitleOut )
end

function splash:leave()
	Tween.stopAll()
end

function splash:mousepressed( ... )
	Gamestate.switch( stateMenu )
end

function splash:update( dt )
	Tween.update( dt )
	Timer.update( dt )
end

function splash:draw()
	love.graphics.setBackgroundColor( self.back.r, self.back.g, self.back.b )
	love.graphics.setFont( font_secretcode_92 )
	
	love.graphics.setColor( self.title.r, self.title.g, self.title.b, self.title.a )
	love.graphics.print( 'color factory', 1024/2 -200, self.title.y )
	
	love.graphics.setColor( self.author.r, self.author.g, self.author.b, self.author.a )
	love.graphics.print( 'by luke perkin', self.author.x, self.author.y )
	
	love.graphics.setColor( self.company.r, self.company.g, self.company.b, self.company.a )
	love.graphics.print( 'locofilm.co.uk', self.company.x, self.company.y )
end

function splash.tweenTitleOut()
	Tween( 4, splash.title, {y = 0, a = 0, g = 255}, 'inQuad', splash.tweenAuthorIn )
end

function splash.tweenAuthorIn()
	Tween( 3, splash.author, { y = 350, a = 255, r = 0, b = 255 }, 'inQuad', splash.tweenAuthorOut )
end

function splash.tweenAuthorOut()
	Tween( 3, splash.author, { y = 600, a = 0, r = 0, b = 0 }, 'outQuad', splash.tweenCompanyIn )
end

function splash.tweenCompanyIn()
	Tween( 3, splash.company, { a = 255 }, 'outQuad' )
end

return splash