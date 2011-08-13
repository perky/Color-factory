-- TLfres v1.1R, the world's easiest way to give a game resolution-independence
-- by Taehl (SelfMadeSpirit@gmail.com)

TLfres = {}	-- namespace

-- Sets up TLfres and sets the screen mode. Default parameters should work fine in most cases.
function TLfres.setScreen(m, wextent, hextent, centered, stretch)
	local w, h = m and m.w or love.graphics.getWidth(), m and m.h or love.graphics.getHeight()
	if m then love.graphics.setMode(w, h, m.full, m.vsync, m.aa or 0) end
	
	wextent,hextent = wextent or 800, hextent or 600
	TLfres.centered, TLfres.e = centered, wextent/2
	TLfres.ws = w/wextent
	TLfres.hs = stretch and h/hextent or TLfres.ws
	if centered then TLfres.wt,TLfres.ht = w/2, w/2-(w-h)/2
	else TLfres.wt,TLfres.ht = 0, 0
	end
end

-- Transforms screen geometry. Call this at the beginning of love.draw().
function TLfres.transform()
	if not TLfres.wt then TLfres.setScreen() end	-- If Robin is being lazy, be awesome and set things up for him
	love.graphics.translate(TLfres.wt, TLfres.ht)
	love.graphics.scale(TLfres.ws, TLfres.hs)
end

-- Draws rectangles at the top and bottom of the screen to ensure proper aspect ratio. Call this at the end of love.draw() if you're not using stretch mode.
function TLfres.letterbox(w,h, c)
	w,h,c = w or 4, h or 3, c or {0,0,0, 255}
	love.graphics.setColor(c)
	
	local tall,de = TLfres.e/w*h, TLfres.e*2
	if TLfres.centered then
		love.graphics.rectangle("fill", -TLfres.e,-TLfres.e, de,TLfres.e-tall)
		love.graphics.rectangle("fill", -TLfres.e,TLfres.e,  de,tall-TLfres.e)
	else
		local o = (TLfres.ws - TLfres.hs) / (TLfres.ws) * (TLfres.e-1)
		love.graphics.rectangle("fill", 0,-o,   de,TLfres.e-tall)
		love.graphics.rectangle("fill", 0,de-o, de,tall-TLfres.e)
	end
end