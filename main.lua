function love.load()
	Object = require("objects/object")
	TileMap = require("objects/tilemap")
	TileLayer = require("objects/tilelayer")
	
	GameWindow = require("window/window")
	Util = require("window/util")
	
	GameWindow.pixelPerfect()
	
	-- Set up pixel font
	local supportedCharacters = [[ !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~◆◇▼▲▽△★☆■□☺☻←↑→↓]]
	font = love.graphics.newImageFont("resources/font_6x8.png", supportedCharacters)
	love.graphics.setFont(font)
	
	-- local supportedCharacters2 = [[ !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~◆◇▼▲▽△★☆]]
	-- font2 = love.graphics.newImageFont("resources/font_8x16.png", supportedCharacters2)
	-- love.graphics.setFont(font2)
	
	require("game")
	
	window = GameWindow{
		title = "Template",
		icon = love.image.newImageData("resources/icon.png"),
		
		screen = {
			scale = 4,
			
			width  = 360,
			height = 240
		},
		
		button = {
			up    = "up",
			down  = "down",
			left  = "left",
			right = "right",
			a     = "z",
			b     = "x",
			start = "return",
			quit  = "escape"
		},
		mouse = {
			cursors = {
				["mouse"] = {
					image = "resources/cursors/mouse.png",
					home = {x = 1, y = 2}
				},
				["hand"] = {
					image = "resources/cursors/hand.png",
					home = {x = 4, y = 1}
				},
				["movable"] = {
					image = "resources/cursors/movable.png",
					home = {x = 4, y = 1}
				},
				["move"] = {
					image = "resources/cursors/move.png",
					home = {x = 4, y = 1}
				},
				["wait"] = {
					image = "resources/cursors/wait.png",
					home = {x = 3, y = 1},
					anim = {
						x = 0,
						y = 0,
						width = 16,
						height = 16,
						time = 3,
						
						{},
						{x = 16},
						{x = 32},
						{x = 48}
					}
				}
			},
			defaultCursor = "wait"
		},
		debug = true,
		
		setup = setup,
		update = update,
		draw = draw
	}
	window:setup()
end

function love.update(dt)
	window:update(dt)
end

function love.draw()
	window:draw()
end
