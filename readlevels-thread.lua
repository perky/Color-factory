require 'love.filesystem'
local this_thread = love.thread.getThread()

local function readLevelFiles( levelDir, levelData )
	local levelFilenames = love.filesystem.getDirectoryItems( levelDir )
	local levelString
	for i, levelFilename in ipairs( levelFilenames ) do
	   local extension = string.sub( levelFilename, -4, -1 )
	   if extension == ".lua" then
   		levelString = love.filesystem.read( levelDir .. levelFilename )
   		this_thread:send( 'level_filename', string.sub(levelFilename, 1, -5) )
   		this_thread:send( 'level_string', levelString )
   		this_thread:demand( 'resume' )
   	end
	end
	return levelData
end

readLevelFiles( "levels/", levelData )
readLevelFiles( "customlevels/", levelData )