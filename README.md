# Love2D Template

It sure is one.

## How to use
0. Click the green *Clone or Download* button, and select *Download ZIP* from the menu that appears.
1. Either keep my `main.lua`, with all its defaults, or make your own.
	1. The file is usually laid out like this: 
		```lua
		function love.load()
			ThingYouNeed1 = require("thingYouNeed1")
			ThingYouNeed2 = require("thingYouNeed2")
			
			GameWindow = require("window/window")
			GameWindow.pixelPerfect() -- Optional
			
			StuffYouNeedToDoBeforeGameStarts()
			
			window = GameWindow{
				title = Game Title,
				icon = Icon Image Data,
				
				-- Want a fixed screen size to work with?
				screen = {
					width = Fixed Screen Width,
					height = ?????????? who knows
				},
				-- Otherwise don't include this
				
				-- Want to use my horrible input system?
				button = {
					buttonName = "keyName"
				},
				-- Otherwise leave it out
				
				-- Want to have a custom cursor, or just want an easy way to get mouse coords?
				mouse = {
					image = Mouse Image, --optional
					home = {x = 0, y = 0} -- again, optional.
					-- you can also just set mouse to true and it'll still give you all the mouse features without hiding the mouse.
				},
				-- Otherwise, you're stuck with it. Just kidding.
				
				-- Built-in console, shortcut menu, etc. Just press =!
				debug = true,
				
				-- Functions to run
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
		```
	2. `game.lua` is not required, but it looks nicer like that.
2. Make game
3. ?????????

## Any problems?

Feel free to make an issue and I'll try to fix it asap! You can also fix it and do a Pull Request, but then I'll have to look up how those work and that takes a really long time and

## Credits

everything created by me except a few libraries in the `util` folder and also `profile.lua` in the `window/debug` folder.

## License

MIT
