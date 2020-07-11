require 'love.filesystem'

local resume_channel = love.thread.getChannel('resume')
local level_string_channel = love.thread.getChannel('level_string')
local level_filename_channel = love.thread.getChannel('level_filename')

local function readLevelFiles( levelDir, levelData )
	local levelFilenames = love.filesystem.getDirectoryItems( levelDir )
	local levelString
	for i, levelFilename in ipairs( levelFilenames ) do
	   local extension = string.sub( levelFilename, -4, -1 )
	   if extension == ".lua" then
   		levelString = love.filesystem.read( levelDir .. levelFilename )
   		level_filename_channel:push( string.sub(levelFilename, 1, -5) )
   		level_string_channel:push( levelString )
   		resume_channel:demand()
   	end
	end
	return levelData
end

readLevelFiles( "levels/", levelData )
readLevelFiles( "customlevels/", levelData )
