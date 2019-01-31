function setup()
	clearColor = {0, 0, 0, 0}
	
	gameText = "Make game!"
	
	if window.debug then
		window.debug.menu:addOption("Hello, world!", function()clearColor = {0.25, 0.5, 1}end, 1)
		window.debug.menu:addDivider(2)
	end
	
	theMap = TileMap(love.graphics.newImage("resources/emoji.png"), 8)
	theMap:newLayer(45, 30)
end

--[[
function emojiBit(x, y)
	local yOne = math.floor(theMap.width)
	
	local function makeTile()
		return (math.random(math.floor(theMap.width / 2)) - 1) * 2 + (math.random(math.floor(theMap.height / 2)) - 1) * 2 * yOne
	end
	
	theMap.layers[1]:setTile(x    , y    , makeTile())
	theMap.layers[1]:setTile(x + 1, y    , makeTile() + 1)
	theMap.layers[1]:setTile(x    , y + 1, makeTile() + yOne)
	theMap.layers[1]:setTile(x + 1, y + 1, makeTile() + yOne + 1)
end

function update()
	if window.frames % 15 == 0 then
		for j = 0, 13, 4 do
			for i = 0, 21, 4 do
				emojiBit(i, j)
			end
		end
		for j = 2, 13, 4 do
			for i = 2, 21, 4 do
				emojiBit(i, j)
			end
		end
	end
end
]]

function update()
	local w, h = theMap.layers[1].width / 2, theMap.layers[1].height / 2
	local wr, hr = math.floor(w), math.floor(h)
	
	theMap.layers[1]:setTile(
		math.floor(  Util.sine(window.frames - 30,  95, wr) *   Util.sine(window.frames - 30, 130) + w),
		math.floor(Util.cosine(window.frames - 30, 100, hr) * Util.cosine(window.frames - 30, 140) + h),
		-1
	)
	theMap.layers[1]:setTile(
		math.floor(  Util.sine(window.frames,  95, wr) *   Util.sine(window.frames, 130) + w),
		math.floor(Util.cosine(window.frames, 100, hr) * Util.cosine(window.frames, 140) + h),
		math.random(theMap.width * theMap.height) - 1
	)
end

function draw()
	local w = window.screen and window.screen.width  or window.width
	local h = window.screen and window.screen.height or window.height
	
	if clearColor[4] and clearColor[4] > 0 and clearColor[4] < 1 then
		love.graphics.setColor(clearColor)
		love.graphics.rectangle("fill", 0, 0, w, h)
	else
		love.graphics.clear(clearColor)
	end
	
	if secretSwitch then
		love.graphics.print(secretSwitch)
		return
	end
	
	local i
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
			w  / 2,
			(h / 2) - 16,
			r,
			2,
			2,
			ox,
			oy
		)
	end
	
	theMap:draw(Util.sine(window.frames, 90, 2), Util.cosine(window.frames, 120, 4))
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
