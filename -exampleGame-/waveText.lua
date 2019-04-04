function setup()
	text = "Wavy text!"
	textw = font:getWidth(text)
	texth = font:getHeight(text)
end

function update()
end

function draw()
	love.graphics.clear{0.25, 0.25, 0.25}
	
	for i = 1, #text do
		local x = (window.screen.width  - textw) / 2 + ((i - 1) * (textw / #text))
		local y = (window.screen.height - texth) / 2 + Util.sine(window.frames + (i * (textw / #text)), 90, texth / 2)
		
		local j, k
		
		love.graphics.setColor(0, 0, 0)
		
		for k = -1, 1 do
			for j = -1, 1 do
				if j ~= 0 or k ~= 0 then
					love.graphics.print(string.sub(text, i, i), x + j, y + k)
				end
			end
		end
		
		love.graphics.setColor(1, 1, 1)
		
		love.graphics.print(string.sub(text, i, i), x, y)
	end
end
