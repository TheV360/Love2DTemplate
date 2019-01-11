local console = {
	enabled = false,
	
	input = "",
	cursor = 1,
	cursorBlink = 0,
	
	inputPrefix = "> ",
	
	log = {
		"+-----------------------------+",
		"| ### ### ###  ## ### #   ### |",
		"| #   # # # #  #  # # #   ##  |",
		"| ### ### # # ##  ### ### ### |",
		"+-----------------------------+"
	},
	logMax = 16,
	
	history = {},
	historyMax = 32,
	currTmp = "",
	currHistory = 0,
	
	errorMessages = {
		"Oof",
		"Yikes",
		"This ain't it",
		")", -- ):
		"Ouch",
		"ERROR",
		"I'm sad"
	},
	
	charWidth = 6,
	lineHeight = 8
}

_true_print = print

-- Hook to print function
print = function(...)
	_true_print(...)
	console:print(...)
end

function console:print(...)
	local i
	local t = {...}
	
	for i = 1, #t do
		self:printLine(tostring(t[i]))
	end
end

function console:printLine(l)
	self.log[#self.log + 1] = l
	
	-- "Scroll"
	if #self.log > self.logMax then
		table.remove(self.log, 1)
	end
end

function console:textinput(key)
	if not self.enabled then
		if key == "`" then
			self.enabled = true
		end
		return
	end
	
	self.input = string.sub(self.input, 1, self.cursor - 1) .. key .. string.sub(self.input, self.cursor)
	self.cursor = self.cursor + 1
	
	self.cursorBlink = 0
end

function console:keypressed(key)
	if not self.enabled then return end
	
	if love.keyboard.isDown("lctrl", "rctrl") then
		if key == "x" then
			love.system.setClipboardText(self.input)
			self:clearInput()
		elseif key == "c" then
			love.system.setClipboardText(self.input)
		elseif key == "v" then
			local c = love.system.getClipboardText()
			
			self.input = string.sub(self.input, 1, self.cursor - 1) .. c .. string.sub(self.input, self.cursor)
			self.cursor = self.cursor + #c
			self.cursorBlink = 0
		elseif key == "z" then
			self:clearInput()
		else
			return
		end
	else
		if key == "up" then
			if self.currHistory == 0 then
				self.currTmp = self.input
			end
			if self.currHistory < #self.history then
				self.currHistory = self.currHistory + 1
				self.input = self.history[self.currHistory]
				self.cursor = #self.input + 1
			end
			self.cursorBlink = 0
		elseif key == "down" then
			if self.currHistory > 0 then
				self.currHistory = self.currHistory - 1
				if self.currHistory == 0 then
					self.input = self.currTmp
				else
					self.input = self.history[self.currHistory]
				end
				self.cursor = #self.input + 1
			end
			self.cursorBlink = 0
		elseif key == "left" and self.cursor > 1 then
			self.cursor = self.cursor - 1
			self.cursorBlink = 0
		elseif key == "right" and self.cursor < #self.input + 1 then
			self.cursor = self.cursor + 1
			self.cursorBlink = 0
		elseif key == "home" then
			self.cursor = 1
		elseif key == "end" then
			self.cursor = #self.input + 1
		elseif key == "return" then
			self:runInput()
		elseif key == "backspace" then
			if #self.input > 0 and self.cursor > 1 then
				self.cursor = self.cursor - 1
				self.input = string.sub(self.input, 1, self.cursor - 1) .. string.sub(self.input, self.cursor + 1)
			end
		else
			return
		end
	end
	
	self.cursorBlink = 0
end

function console:runInput()
	local line = self.input
	
	self:clearInput()
	self.currTmp = nil
	self.currHistory = 0
	
	if line == "`" then self.enabled = false; return; end
	if line == "~" then self.log = {}; return; end
	if line == "help" then
		self:printLine("~~~ Help ~~~~~~~~~~~")
		self:printLine("`    - exit console ")
		self:printLine("~    - clear console")
		self:printLine("help - display this ")
		self:printLine("~~~~~~~~~~~~~~~~~~~~")
		self:printLine("Anything else will  ")
		self:printLine("be treated as a Lua ")
		self:printLine("statement.          ")
		self:printLine("~~~~~~~~~~~~~~~~~~~~")
		self:printLine("If you put = at the ")
		self:printLine("beginning of a line,")
		self:printLine("it shows the result.")
		self:printLine("~~~~~~~~~~~~~~~~~~~~")
		
		return
	end
	
	-- Show line in console
	print(self.inputPrefix .. line)
	
	-- Add line to history
	table.insert(self.history, 1, line)
	-- If history passed its max, remove a thing.
	if #self.history > self.historyMax then
		table.remove(self.history)
	end
	
	-- If line has = at start, encase the code in print()
	if string.sub(line, 1, 1) == "=" then
		self:runLine("print(" .. string.sub(line, 2) .. ")")
	else
		self:runLine(line)
	end
end

function console:runLine(code)
	local HANDLE_WITH_CARE = loadstring(code)
	local status, err = pcall(HANDLE_WITH_CARE)
	if not status then
		local errMsg = self.errorMessages[math.random(1, #self.errorMessages)]
		print(errMsg .. ": " .. err)
	else
		if err then print(tostring(err)) end
	end
end

function console:update()
	if not self.enabled then return end
	self.cursorBlink = self.cursorBlink + 1
end

function console:clearInput()
	self.input = ""
	self.cursor = 1
end

function console:draw()
	if not self.enabled then return end
	
	local i
	local bottomDist = (#self.log + 1) * (self.lineHeight * window.screen.scale)
	
	love.graphics.setColor(0.25, 0.25, 0.25, 0.5)
	love.graphics.rectangle("fill", 0, window.height - bottomDist, window.width, bottomDist)
	
	love.graphics.setColor(1, 1, 1)
	for i = 1, #self.log do
		love.graphics.print(self.log[i], 0, window.height - (bottomDist - (self.lineHeight * window.screen.scale * (i - 1))), 0, window.screen.scale)
	end
	
	love.graphics.setColor(0.5, 0.75, 1)
	love.graphics.print(self.inputPrefix .. self.input, 0, window.height - (self.lineHeight * window.screen.scale), 0, window.screen.scale)
	
	love.graphics.setColor(0.25, 0.5, 1, 0.5 + cosine(self.cursorBlink, 90, 0.5))
	love.graphics.print("|", ((self.cursor + 1) * self.charWidth - 2) * window.screen.scale, window.height - (self.lineHeight * window.screen.scale), 0, window.screen.scale)
end

return console
