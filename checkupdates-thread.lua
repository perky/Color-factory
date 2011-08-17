require 'socket.http'
require 'socket.url'
require 'ltn12'
require 'luahub.init'

local this_thread = love.thread.getThread()
local GAME_VERSION = this_thread:demand( 'GAME_VERSION' )

local function versionToTable( version )
   local t = {}
   for match, _ in string.gmatch( version, '(%d+)%.?' ) do
      t[#t+1] = tonumber(match)
   end
   return t
end

local function checkForNewerVersion()
   local tags = luahub.repos.tags( 'color-factory', 'perky' )
   local thisVersion = versionToTable( GAME_VERSION )
   local latestVersion = nil
   for remoteVersionString, _ in pairs( tags ) do
      local remoteVersions = versionToTable( versionString )
      for i, remoteVersion in ipairs(remoteVersions) do
         if thisVersion[i] then
            if remoteVersion > thisVersion[i] then
               latestVersion = remoteVersionString
               break
            elseif remoteVersion < thisVersion[i] then
               break
            end
         else
            latestVersion = remoteVersionString
            break
         end
      end
   end
   

   if latestVersion then
      local downloadUrl = string.format( "https://github.com/downloads/perky/Color-factory/colorfactory-%s.love", latestVersion )
      local tinyurlApiUrl = string.format( "http://tinyurl.com/api-create.php?url=%s", downloadUrl )
      local get, response = socket.http.request( tinyurlApiUrl )
      print(response)
      if response then
         this_thread:send( 'tiny_url', get )
      end
   end
end

checkForNewerVersion()