require 'socket.http'
GAMESTATS_HOST = "http://localhost:3000"
local this_thread = love.thread.getThread()

local function request_url( url )
   url = string.format( "%s/%s", GAMESTATS_HOST, url )
   local body, res = socket.http.request(url)
   if body then
      print(body)
      this_thread:send('body', body)
   end
end

while true do
   local url = this_thread:demand( 'url' )
   if url then request_url( url ) end
end