gamestats = {}
gamestats.game_name = "color_factory"
gamestats.host = "http://evening-sword-380.heroku.com"
gamestats.thread = love.thread.newThread('gamestats_thread','gamestats/thread.lua')
gamestats.blocking = false
gamestats.active = true

local this_thread = love.thread.getThread()
gamestats.thread:start()

function gamestats:game_session_start()
   if not self.active then return end
   
   self.game_start = love.timer.getTime()
   local url = string.format( '%s/game_session/new/%s', self.host, self.game_name )
   self.is_waiting_for_id = true
   self.thread:send( 'url', url )
end

function gamestats:game_session_end()
   if not self.game_session_id or not self.active then return end
   
   local this_thread = love.thread.getThread()
   local duration = love.timer.getTime() - self.game_start
   local url = string.format( '%s/game_sessions/%s/finish/%i', self.host, self.game_session_id, duration )
   self.thread:send( 'url', url )
   if self.blocking then this_thread:demand( 'body' ) end
end

function gamestats:level_session_start()
   self.level_start = love.timer.getTime()
end

function gamestats:level_session_end( level, score )
   if not self.game_session_id or not self.active then return end
   local duration = love.timer.getTime() - self.level_start
   local url = string.format( '%s/game_sessions/%s/level_sessions/new/%s/%i/%i', self.host, self.game_session_id, level, duration, score )
   self.thread:send( 'url', url )
   if self.blocking then this_thread:demand( 'body' ) end
end

function gamestats:setBlocking( isBlocking )
   self.blocking = isBlocking
end

function gamestats:update( dt )
   local body = this_thread:receive( 'body' )
   if body and self.is_waiting_for_id then
      self.game_session_id = body
      self.is_waiting_for_id = false
   end
end