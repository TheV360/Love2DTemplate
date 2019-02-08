function setup()
	clearColor = {0, 0, 0, 0}
	
	gameText = "Make game!"
	
	if window.debug then
		window.debug.menu:addOption("Hello, world!", function()clearColor = {0.25, 0.5, 1}end, 1)
		window.debug.menu:addDivider(2)
	end
	
	colorPal = {
		{0.0, 0.1, 0.2},
		{0.1, 0.2, 0.3}
	}
	
	checkerboardSize = 12
end

function update()
end

function draw()
	local i, j
	
	local w = window.screen and window.screen.width  or window.width
	local h = window.screen and window.screen.height or window.height
	
	love.graphics.clear(colorPal[1])
	
	if secretSwitch then
		love.graphics.print(secretSwitch)
		return
	end
	
	local mw, mh = math.floor(w / checkerboardSize), math.floor(h / checkerboardSize)
	
	love.graphics.setColor(colorPal[2])
	for j = 0, mh - 1 do
		for i = 0, mw - 1 do
			if (j + i) % 2 > 0 then
				love.graphics.rectangle("fill", i * checkerboardSize, j * checkerboardSize, checkerboardSize, checkerboardSize)
			end
		end
	end
	
	for i = 1, 36, 4 do
		local j = i * 10
		
		local r = (2 * math.pi * ((window.frames + j) / 360))
		local ox = Util.sine(window.frames + j, 120, 24, true) + Util.cosine(window.frames + j, 160, 8, true)
		local oy = Util.cosine(window.frames + j, 120, 32, true) + Util.sine(window.frames + j, 160, 8, true)
		
		love.graphics.setColor(0, 0, 0, 0.25)
		printCenter(
			gameText,
			w  / 2,
			(h / 2) - 15,
			r,
			2,
			2,
			ox,
			oy
		)
		
		love.graphics.setColor(
			Util.sine(window.frames + j,  90, 0.5, true) + 0.5,
			Util.sine(window.frames + j, 180, 0.5, true) + 0.5,
			Util.sine(window.frames + j, 270, 0.5, true) + 0.5
		)
		printCenter(
			gameText,
			w / 2,
			h / 2 - 16,
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
