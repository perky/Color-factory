require 'socket.http'
local this_thread = love.thread.getThread()
local main_thread = love.thread.getThread('main')

local function request( url )
   print('requesting url')
   local body, res = socket.http.request( url )
   if body then
      print(body)
      main_thread:send( 'body', body )
   else
      main_thread:send( 'body', 'ERROR' )
   end
end

while true do
   local url = this_thread:demand('url')
   if url then request( url ) end
end