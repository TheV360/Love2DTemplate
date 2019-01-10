require "object"

require "modules/watch"
require "modules/v360"

require "game"

function love.load()
	window = {
		-- Game Title & Save Folder Name
		title = "Template",
		version = "v0.0",
		icon = nil,
		
		-- Window Position
		x = 0, y = 0,
		
		-- Window Size
		width = 0,
		height = 0,
		fullscreen = false,
		
		-- Fonts
		fonts = {},
		
		-- Screen Size
		screen = {
			enabled = true,
			canvas = nil,
			
			-- Screen options
			width = 360,
			height = 240,
			
			-- Screen scaling
			scale = 2,
			x = 0, y = 0
		},
		
		-- Backdrop (For Screen Scaling)
		backdrop = {
			enabled = false,
			
			image = nil,
			quad = nil,
			width = 0,
			height = 0
		},
			
		-- Screen shake
		shake = {
			enabled = false,
			screenCoords = false,
			extremes = true,
			windowBonk = true,
			
			-- Shake X and Y
			x = 0, y = 0,
			
			-- Calculated Shake X and Y
			cx = 0, cy = 0
		},
		
		-- Game Tick
		running = true,
		tick = 0.0,
		tickMaximum = 1.0 / 60.0,
		frames = 0,
		trueFrames = 0,
		
		-- Debug console, more general debug business
		debug = {
			enabled = true,
			
			profile = false,
			
			fpsPlot = {},
			
			console = require("modules/debug/console"),
			menu = require("modules/debug/menu"),
			stats = require("modules/debug/stats")
		}
	}
	
	if window.debug.enabled then
		window.debug.menu:addOption("Open Console", openConsole)
		window.debug.menu:addOption("Take Screenshot", takeScreenshot)
		window.debug.menu:addOption("Exit Game", love.event.quit)
		
		if window.debug.profile then
			love.profiler = require("modules/profile")
			love.profiler.hookall("Lua")
			love.profiler.start()
		end
	end
	
	window.fullscreen = false
	
	-- Get window position
	window.x, window.y = love.window.getPosition()
	
	-- Actual scaling of the window
	window.width = (window.screen.width * window.screen.scale)
	window.height = (window.screen.height * window.screen.scale)
	if window.backdrop.enabled then
		window.width = window.width + 8
		window.height = window.height + 8
	end
	updateScreen(window.width, window.height)
	
	-- Get everything about the window set up, and get a save folder
	love.window.setMode(window.width, window.height, {vsync = true, resizable = true, fullscreen = window.fullscreen})
	love.window.setTitle(window.title)
	love.filesystem.setIdentity(window.title)
	
	-- Set up pixel perfection
	love.graphics.setDefaultFilter("nearest", "nearest", 1)
	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(1)
	
	-- Set up pixel font
	local supportedCharacters = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~◆◇▼▲▽△★☆"
	window.fonts.font6x8 = love.graphics.newImageFont("resources/font_6x8.png", supportedCharacters)
	love.graphics.setFont(window.fonts.font6x8)
	
	-- Fix window icon
	window.icon = love.image.newImageData("resources/icon.png")
	love.window.setIcon(window.icon)
	
	if window.backdrop.enabled then
		-- Set up backdrop repetition
		window.backdrop.image = love.graphics.newImage("resources/backdrop.png")
		window.backdrop.image:setWrap("repeat", "repeat")
		window.backdrop.width = window.backdrop.image:getWidth()
		window.backdrop.height = window.backdrop.image:getHeight()
		
		-- Set up backQuad
		window.backdrop.quad = love.graphics.newQuad(0, 0, window.width + window.backdrop.width, window.height + window.backdrop.height, window.backdrop.width, window.backdrop.height)
	end
	
	-- Make screen canvas
	window.screen.canvas = love.graphics.newCanvas(window.screen.width, window.screen.height)
	
	-- These make watches, things that check if a thing is true, then output 3 things:
		-- downTime[]: How long it's been true
		-- press[]:    If it just became true
		-- release[]:  If it just became false
	-- Also, for QoL, there's another table that just says if it's true or not. (down[])
	button = Watch.new({"up", "down", "left", "right", "a", "b", "start", "debug", "quit"}, function(key) return love.keyboard.isDown(button.map[key]) end)
	mouse = Watch.new({1, 2, 3, 4, 5}, function(key) return love.mouse.isDown(key) end)
	
	-- So I use one as a table and store the button mappings
	button.map = {
		up    = "up",
		down  = "down",
		left  = "left",
		right = "right",
		a     = "z",
		b     = "x",
		start = "return",
		debug = "/",
		quit  = "escape"
	}
	
	-- And store the X and Y coordinates of the mouse in the other...
	mouse.x, mouse.y = love.mouse.getPosition()
	
	if setup then
		setup()
	end
end

function love.update(dt)
	-- Run at a constant frame rate even with VSYNC off
	dt = math.min(dt, window.tickMaximum)
	
	window.tick = window.tick + dt
	
	if window.tick < window.tickMaximum then
		return
	else
		window.tick = window.tick - window.tickMaximum
	end
	
	-- Update button & mouse
	button:update()
	mouse:update()
	
	-- Update mouse coordinates
	mouse.x, mouse.y = love.mouse.getPosition()
	
	if window.running then
		-- Update screen coordinates
		if window.shake.enabled then
			window.shake.cx, window.shake.cy = calculateShake()
		else
			window.x, window.y = love.window.getPosition()
		end
		
		if update then
			update()
		end
		
		-- Autoupdate window shake
		if not window.shake.enabled and (window.shake.x ~= 0 or window.shake.y ~= 0) then
			window.shake.enabled = true
		elseif window.shake.enabled and (window.shake.x == 0 and window.shake.y == 0) then
			window.shake.enabled = false
			
			if canMoveWindow() then love.window.setPosition(window.x, window.y) end
		end
		
		-- Increment frames
		window.frames = window.frames + 1
	end
	
	if window.debug.enabled then
		window.debug.stats.enabled = love.keyboard.isDown("rshift")
		
		if button.release["debug"] then
			if window.running then
				window.screen.x = window.screen.x + (16 * window.screen.scale)
				window.debug.menu.enabled = true
			else
				updateScreen(window.width, window.height)
				window.debug.menu.enabled = false
			end
			
			window.running = not window.running
		end
	end
		
	-- Increment true frames
	window.trueFrames = window.trueFrames + 1
	
	if window.debug.enabled then
		window.debug.console:update()
		window.debug.menu:update()
		window.debug.stats:update()
	end
end

function love.draw()
	if window.backdrop.enabled then
		love.graphics.draw(window.backdrop.image, window.backdrop.quad, -(math.floor(window.frames / 2) % window.backdrop.width), -(math.floor(window.frames / 2) % window.backdrop.height))
	end
	
	if window.screen.enabled then
		if draw then window.screen.canvas:renderTo(draw) end
		
		-- Draw scaled screen
		if window.running then
			love.graphics.setColor(1, 1, 1)
		else
			love.graphics.setColor(0.2, 0.4, 0.6)
		end
		
		-- Add screen shake
		if window.shake.enabled then
			if canMoveWindow() then
				-- I n n o v a t i o n
				love.window.setPosition(window.x + window.shake.cx, window.y + window.shake.cy)
				
				love.graphics.draw(window.screen.canvas, window.screen.x - window.shake.cx, window.screen.y - window.shake.cy, 0, window.screen.scale)
			else
				love.graphics.draw(window.screen.canvas, window.screen.x + window.shake.cx, window.screen.y + window.shake.cy, 0, window.screen.scale)
			end
		else
			love.graphics.draw(window.screen.canvas, window.screen.x, window.screen.y, 0, window.screen.scale)
		end
	else
		draw()
		
		if window.shake.enabled and canMoveWindow() then
			love.window.setPosition(window.x + window.shake.cx, window.y + window.shake.cy)
		end
	end
	
	if window.debug.enabled then
		window.debug.console:draw()
		window.debug.menu:draw()
		window.debug.stats:draw()
	end
	
	if window.profile and window.frames % 60 == 0 then
		love.report = love.profiler.report("time", 20)
		print(love.report)
		love.profiler.reset()
	end
end

function love.keypressed(key)
	if key == "rctrl" and window.debug.enabled then
		local i, j
		local alert = [[+----------------------------------------+
|    Debugging. Window won't respond.    |
| Type "cont" in the console to continue |
+----------------------------------------+]]
		
		window.fullscreen = false
		love.window.setFullscreen(window.fullscreen)
		
		love.graphics.setColor(0, 0, 0)
		for j = -3, 3 do
			for i = -3, 3 do
				love.graphics.print(alert, 4 + i, 4 + j, 0, 2, 2)
			end
		end
		love.graphics.setColor(1, 0.25, 0.5)
		love.graphics.print(alert, 4, 4, 0, 2, 2)
		love.graphics.present()
		print("To resume the program, enter \"cont\"\n")
		debug.debug()
	elseif key == "f4" then
		window.fullscreen = not window.fullscreen
		love.window.setFullscreen(window.fullscreen)
	end
	
	if _keypressed then
		_keypressed(key)
	end
end

function love.resize(width, height)
	window.width = width
	window.height = height
	
	if window.screen.enabled then
		updateScreen(width, height)
	end
	
	if _resize then
		_resize(width, height)
	end
end

function updateScreen(width, height)
	local newWidth, newHeight
	
	window.screen.scale = math.max(1, math.floor(math.min(width / window.screen.width, height / window.screen.height)))
	newWidth = window.screen.width * window.screen.scale
	newHeight = window.screen.height * window.screen.scale
	window.screen.x = math.floor(width / 2) - math.floor(newWidth / 2)
	window.screen.y = math.floor(height / 2) - math.floor(newHeight / 2)
	
	-- Update backdrop
	window.backdrop.quad = love.graphics.newQuad(0, 0, width + window.backdrop.width, height + window.backdrop.height, window.backdrop.width, window.backdrop.height)
end

function calculateShake()
	local ox, oy
	
	if window.shake.extremes then
		ox = math.random() >= .5 and window.shake.x or -window.shake.x
		oy = math.random() >= .5 and window.shake.y or -window.shake.y
	else
		ox = math.random(-window.shake.x, window.shake.x)
		oy = math.random(-window.shake.y, window.shake.y)
	end
	
	if window.shake.screenCoords then
		ox = ox * window.screen.scale
		oy = oy * window.screen.scale
	end
	
	ox = math.floor(ox)
	oy = math.floor(oy)
	
	return ox, oy
end

function openConsole()
	error("todo")
end

function takeScreenshot()
	if window.backdrop.enabled then
		love.graphics.captureScreenshot(window.title .. " " .. window.version .. " " .. os.time() .. ".png")
	else
		window.screen.canvas:newImageData():encode("png", window.title .. " " .. window.version .. " " .. os.time() .. ".png")
	end
end

function canMoveWindow()
	return window.shake.windowBonk and love.window.isVisible() and not (window.fullscreen or love.window.isMaximized())
end

function mouseConvert(x, y)
	return math.floor((x - window.screen.x) / window.screen.scale), math.floor((y - window.screen.y) / window.screen.scale)
end

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--  /██    /██  /██████   /██████   /██████  /████████                  /██       --
-- | ██   | ██ /██__  ██ /██__  ██ /███_  ██|__  ██__/                 | ██       --
-- | ██   | ██|__/  \ ██| ██  \__/| ████\ ██   | ██  /██████   /███████| ███████  --
-- |  ██ / ██/   /█████/| ███████ | ██ ██ ██   | ██ /██__  ██ /██_____/| ██__  ██ --
--  \  ██ ██/   |___  ██| ██__  ██| ██\ ████   | ██| ████████| ██      | ██  \ ██ --
--   \  ███/   /██  \ ██| ██  \ ██| ██ \ ███   | ██| ██_____/| ██      | ██  | ██ --
--    \  █/   |  ██████/|  ██████/|  ██████/   | ██|  ███████|  ███████| ██  | ██ --
--     \_/     \______/  \______/  \______/    |__/ \_______/ \_______/|__/  |__/ --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------