local menu = {}

function menu:init()
end

function menu:enter( previous )
	
end

function menu:leave()
end

function menu:update( dt )
end

function menu:draw()
	love.graphics.setBackgroundColor( 30, 30, 30 )
end

function menu:mousepressed( x, y, key )
	Gamestate.switch( stateLevel, 1 )
	menu_song:setLooping( false )
end

return menu