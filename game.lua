function setup()
	window.debug.menu:addOption("Hello, world!", function()love.graphics.setBackgroundColor(0.25, 0.5, 1)end, 1)
end

function draw()
	love.graphics.clear()
	
	local i
	for i = 1, 36, 4 do
		local j = i * 10
		
		local r = (2 * math.pi * ((window.frames + j) / 360))
		local ox = sine(window.frames + j, 120, 24, true) + cosine(window.frames + j, 160, 8, true)
		local oy = cosine(window.frames + j, 120, 32, true) + sine(window.frames + j, 160, 8, true)
		
		love.graphics.setColor(0, 0, 0, 0.25)
		printCenter(
			"Make game!",
			window.screen.width  / 2,
			(window.screen.height / 2) - 15,
			r,
			2,
			2,
			ox,
			oy
		)
		
		love.graphics.setColor(
			sine(window.frames + j,  90, 0.5, true) + 0.5,
			sine(window.frames + j, 180, 0.5, true) + 0.5,
			sine(window.frames + j, 270, 0.5, true) + 0.5
		)
		printCenter(
			"Make game!",
			window.screen.width  / 2,
			(window.screen.height / 2) - 16,
			r,
			2,
			2,
			ox,
			oy
		)
	end
end

function printCenter(s, x, y, r, sx, sy, ox, oy)
	s = s or ""
	x = x or 0
	y = y or 0
	r = r or 0
	sx = sx or 1
	sy = sy or sx
	ox = ox or 0
	oy = oy or 0
	
	local currFont = love.graphics.getFont()
	local width  = currFont:getWidth(s)
	local height = currFont:getHeight()
	
	love.graphics.print(s, x, y, r, sx, sy, ox + (width / 2), oy + (height / 2))
end
