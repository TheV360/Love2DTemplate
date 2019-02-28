function love.load()
	Object = require("objects/object")
	TileMap = require("objects/tilemap")
	TileLayer = require("objects/tilelayer")
	
	GameWindow = require("window/window")
	GameWindow.pixelPerfect()
	
	-- Set up pixel font
	local supportedCharacters = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~◆◇▼▲▽△★☆■□"
	font = love.graphics.newImageFont("resources/font_6x8.png", supportedCharacters)
	love.graphics.setFont(font)
	
	require "game"
	
	window = GameWindow{
		title = "Template",
		icon = love.image.newImageData("resources/icon.png"),
		
		screen = {
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
			image = love.graphics.newImage("resources/mouse.png"),
			home = {x = 1, y = 2}
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
