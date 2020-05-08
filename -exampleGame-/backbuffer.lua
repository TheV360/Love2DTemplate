function setup()
	neat = love.graphics.newCanvas(window.screen.width, window.screen.height)
end

function update()
end

function draw()
	
	local tmp = love.graphics.getCanvas()
	
	love.graphics.setCanvas(neat)
	
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(
		window.screen.canvas,
		window.screen.width / 2, window.screen.height / 2,
		math.rad(window.frames), 1, 1,
		-- Util.sine(window.frames, 90, 0.4) + 0.5, Util.cosine(window.frames, 100, 0.4) + 0.5,
		window.screen.width / 2, window.screen.height / 2
	)
	
	love.graphics.setColor(HSL(window.frames / 360, 0.5, 0.5))
	love.graphics.circle("fill", window.mouse.sx - 4, window.mouse.sy - 4, 16)
	
	love.graphics.setCanvas(tmp)
	
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.clear()
	love.graphics.draw(neat, 0, 0)
end

function HSL(h, s, l, a)
	if s <= 0 then return l, l, l, a end
	
	h = h * 6
	
	local c = (1 - math.abs(2 * l - 1))*s
	local x = (1 - math.abs(h % 2 - 1))*c
	local m = (l - .5 * c)
	
	if     h < 1 then r, g, b = c, x, 0
	elseif h < 2 then r, g, b = x, c, 0
	elseif h < 3 then r, g, b = 0, c, x
	elseif h < 4 then r, g, b = 0, x, c
	elseif h < 5 then r, g, b = x, 0, c
	else              r, g, b = c, 0, x
	end
	
	return r + m, g + m, b + m, a
end
