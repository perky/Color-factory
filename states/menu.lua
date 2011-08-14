require "MenuButton"
local menu = Gamestate.new()

function menu:init()
	self.levelData = self:loadLevels()
	self.buttons = {}
	for i, level in ipairs( self.levelData ) do
		self.buttons[#self.buttons+1] = MenuButton:new( 100, 100+(i-1)*28, level.name, self.runLevel, self, level )
	end
end

function menu:enter( previous )
	
end

function menu:update( dt )
	for i, button in ipairs( self.buttons ) do button:update(dt) end
end

function menu:draw()
	love.graphics.setBackgroundColor( 30, 30, 30 )
	for i, button in ipairs( self.buttons ) do button:draw() end
end

function menu:mousepressed( x, y, key )
end

function menu:mousereleased( x, y, key )
	for i, button in ipairs( self.buttons ) do button:mousereleased( x, y, key ) end
end

function menu:runLevel( level )
	Gamestate.switch( stateLevel, level )
	menu_song:setLooping( false )
end

function menu:loadLevels()
	local lfs = love.filesystem
	
	levelFilenames = lfs.enumerate( "levels/" )
	local levelChunks = {}
	local levelData = {}
	for i, levelFilename in ipairs( levelFilenames ) do
		local chunkPos =  #levelChunks+1
		levelChunks[chunkPos] = lfs.load( "levels/" .. levelFilename )
		levelData[#levelData+1] = levelChunks[chunkPos]() 
	end
	
	return levelData
end

return menu