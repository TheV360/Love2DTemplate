Object = require("object")

function love.load()
	TileMap = require("objects/tilemap")
	TileLayer = require("objects/tilelayer")
	
	Window = require("window")
	Window.pixelPerfect()
	
	-- Set up pixel font
	local supportedCharacters = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~◆◇▼▲▽△★☆■□"
	font = love.graphics.newImageFont("resources/font_6x8.png", supportedCharacters)
	love.graphics.setFont(font)
	
	require "game"
	
	window = Window{
		title = "Template",
		icon = love.image.newImageData("resources/icon.png"),
		
		screen = {
			width  = 360,
			height = 240
		},
		
		button = true,
		mouse = {
			image = love.graphics.newImage("resources/mouse.png")
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
