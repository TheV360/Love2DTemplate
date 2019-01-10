local menu = {
	enabled = false,
	
	option = {
		width = 256,
		height = 32,
		padding = 8
	},
	
	options = {}
}

function menu:addOption(text, callback, index)
	local o = {text = text or "Option", callback = callback or function()end}
	if index then
		table.insert(self.options, index, o)
	else
		table.insert(self.options, o)
	end
end

function menu:update()
	if not self.enabled then return end
	
	local i, c
	
	for i, c in ipairs(self.options) do
		c.hover = pointSquare(
			mouse.x,
			mouse.y,
			8,
			(i * (self.option.height + self.option.padding)) - self.option.height,
			self.option.width,
			self.option.height
		)
		if mouse.release[1] and c.hover then
			c.callback()
		end
	end
end

function menu:draw()
	if not self.enabled then return end
	
	local i, c
	
	-- Pulse multiplier
	-- It makes colors look neat, it makes a pulse effect, it is multiplied.
	local pm = sine(window.trueFrames, 90, 0.1) + 0.9
	
	love.graphics.setColor(1, 1, 1)
	for i, c in ipairs(self.options) do
		love.graphics.setColor(0.1, 0.2, 0.4, 0.25)
		love.graphics.rectangle("fill", 12, 4 + (i * (self.option.height + self.option.padding)) - self.option.height, self.option.width, self.option.height)
	end
	for i, c in ipairs(self.options) do
		if c.hover then
			if mouse.down[1] then
				love.graphics.setColor(0.1 * pm, 0.2 * pm, 0.4 * pm)
			else
				love.graphics.setColor(0.2 * pm, 0.4 * pm, 0.8 * pm)
			end
		else
			love.graphics.setColor(0.3, 0.6, 1)
		end
		love.graphics.rectangle("fill", 8, (i * (self.option.height + self.option.padding)) - self.option.height, self.option.width, self.option.height)
	end
	for i, c in ipairs(self.options) do
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(c.text, 12, 4 + (i * (self.option.height + self.option.padding)) - self.option.height, 0, 2, 2)
	end
end

return menu
