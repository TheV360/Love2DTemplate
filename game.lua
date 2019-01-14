TileMap = require("modules/objects/tilemap")
TileLayer = require("modules/objects/tilelayer")

function setup()
	clearColor = {0, 0, 0}
	
	gameText = "Make game!"
	
	window.debug.menu:addOption("Hello, world!", function()clearColor = {0.25, 0.5, 1}end, 1)
	window.debug.menu:addDivider(2)
	
	-- window.loveFunctions:addLoveFunctionWithRunCheck("keypressed", "Game", function(key)
	-- 	print("You have pressed the  " .. key .. " key .")
	-- end)
	
	theMap = TileMap(love.graphics.newImage("resources/emoji.png"), 34 / 2)
	theMap:newLayer(22, 15)
	local l1 = theMap.layers[1]
end

function update()
	if window.frames % 5 == 0 then
		for j = 0, 7 do
			for i = 0, 7 do
				theMap.layers[1]:setTile(i, j, math.random(0, theMap.width * theMap.height - 1))
			end
		
		end
	end
end

function draw()
	-- love.graphics.clear(clearColor)
	
	love.graphics.setColor(clearColor)
	love.graphics.rectangle("fill", 0, 0, window.screen.width, window.screen.height)
	
	local i
	for i = 1, 36, 4 do
		local j = i * 10
		
		local r = (2 * math.pi * ((window.frames + j) / 360))
		local ox = sine(window.frames + j, 120, 24, true) + cosine(window.frames + j, 160, 8, true)
		local oy = cosine(window.frames + j, 120, 32, true) + sine(window.frames + j, 160, 8, true)
		
		love.graphics.setColor(0, 0, 0, 0.25)
		printCenter(
			gameText,
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
			gameText,
			window.screen.width  / 2,
			(window.screen.height / 2) - 16,
			r,
			2,
			2,
			ox,
			oy
		)
	end
	
	theMap:draw()
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
