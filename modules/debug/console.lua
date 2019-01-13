local Console = {
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
	historyNow = "",
	currHistory = 0,
	
	tab = {},
	currTab = 0,
	currTabTmp = "",
	
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
	lineHeight = 8,
	
	tabStep = 8,
	
	validVariable = "[%a][%a%d]*",
	vagueIdentifier = "[%a][%a%d%.%:]*"
}

_true_print = print

-- Hook to print function
print = function(...)
	_true_print(...)
	Console:print(...)
end

-- Converts this: a[tab]b[tab][tab]d
--       to this: a_______b_______________d
-- Used when you print("multiple", "arguments", "like", "this")
function Console:spaceArguments(...)
	local t = {...}
	local i
	local r = tostring(t[1])
	
	for i = 2, #t do
		r = r .. string.rep(" ", 8 - #r % self.tabStep) .. t[i]
	end
	
	return r
end

function Console:print(...)
	self.log[#self.log + 1] = self:spaceArguments(...)
	
	-- "Scroll"
	if #self.log > self.logMax then
		table.remove(self.log, 1)
	end
end

function Console:addAtCursor(str)
	self.input = string.sub(self.input, 1, self.cursor - 1) .. str .. string.sub(self.input, self.cursor)
	self.cursor = self.cursor + #str
end

function Console:textinput(key)
	if not self.enabled then
		if key == "`" then
			self.enabled = true
		end
		return
	end
	
	self:addAtCursor(key)
	
	self.cursorBlink = 0
end

function Console:keypressed(key)
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
				self.historyNow = self.input
			end
			if self.currHistory < #self.history then
				self.currHistory = self.currHistory + 1
				self:clearInput()
				self:addAtCursor(self.history[self.currHistory])
			end
			self.cursorBlink = 0
		elseif key == "down" then
			if self.currHistory > 0 then
				self.currHistory = self.currHistory - 1
				self:clearInput()
				if self.currHistory == 0 then
					self:addAtCursor(self.historyNow)
				else
					self:addAtCursor(self.history[self.currHistory])
				end
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
		elseif key == "tab" then
			if #self.input > 0 then
			-- if not self.tabCalc then
				-- -- Oof, we have to calculate the things
				-- self.tab = {}
				
				-- So if you press tab here love.graphics.re|(), it only sees "love.graphics.re" [VALID] and not "love.graphics.re()" [INVALID]
				local inputCur = string.sub(self.input, 1, self.cursor - 1)
				local start, stop = inputCur:find(self.vagueIdentifier .. "$") -- grabs anything that looks like an identifier
				-- also must be at the end, hence the $
				
				-- Yikes we found nothing
				if not start then return end
				
				-- Yay, we found something that looks like an identifier!
				inputCur = string.sub(inputCur, start, stop)
				
				-- ...but is it really?
				local isValid, items = self:isValidIdentifier(inputCur)
				
				-- It wasn't
				if not isValid then return end
				
				-- It was!
				local i
				local tableTrace = _G -- _G contains itself oh god oh fuck
				
				-- Trace down to the table we are in right now
				for i = 1, #items - 1 do
					tableTrace = tableTrace[items[i]]
					if not tableTrace then return end
				end
				
				-- Find something that looks like it!
				for i in pairs(tableTrace) do
					if string.sub(i, 1, #items[#items]) == items[#items] then
						self:addAtCursor(string.sub(i, #items[#items] + 1) .. string.sub(self.input, self.cursor))
						return
					end
				end
			-- end
			end
		else
			return
		end
	end
	
	self.cursorBlink = 0
end

function Console:runInput()
	local line = self.input
	
	self:clearInput()
	self.historyNow = nil
	self.currHistory = 0
	
	if line == "`" then self.enabled = false; return; end
	if line == "~" then self.log = {}; return; end
	if line == "help" then
		self:print("~~~ Help ~~~~~~~~~~~")
		self:print("`    - exit console ")
		self:print("~    - clear console")
		self:print("help - display this ")
		self:print("~~~~~~~~~~~~~~~~~~~~")
		self:print("Anything else will  ")
		self:print("be treated as a Lua ")
		self:print("statement.          ")
		self:print("~~~~~~~~~~~~~~~~~~~~")
		self:print("If you put = at the ")
		self:print("beginning of a line,")
		self:print("it shows the result.")
		self:print("~~~~~~~~~~~~~~~~~~~~")
		
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

function Console:runLine(code)
	local HANDLE_WITH_CARE = loadstring(code)
	local status, err = pcall(HANDLE_WITH_CARE)
	if not status then
		local errMsg = self.errorMessages[math.random(1, #self.errorMessages)]
		print(errMsg .. ": " .. err)
	else
		if err then print(tostring(err)) end
	end
end

function Console:clearInput()
	self.input = ""
	self.cursor = 1
end

-- one
function Console:isValidVariable(str)
	return str:find(self.validVariable) and true or false
end

-- Multiple stuff
function Console:isValidIdentifier(str)
	local i
	
	-- variables (cursorBlink, arg2, etc)
	local vars = {}
	
	-- delimiters (. and :)
	local delCount = 0
	
	-- You can't be yourself twice
	local alreadySelf = false
	
	for i in str:gfind("[%.%:]") do
		-- Can't do this: a.b:c.d
		-- I don't accept any delimiters once you use a :.
		if alreadySelf then
			return false
		end
		if i == ":" then
			alreadySelf = true
		end
		delCount = delCount + 1
	end
	
	for i in str:gfind(self.validVariable) do
		table.insert(vars, i)
	end
	
	return delCount + 1 == #vars, vars
end

function Console:update()
	if not self.enabled then return end
	self.cursorBlink = self.cursorBlink + 1
end

function Console:draw()
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
	love.graphics.print("■", (self.cursor + 1) * self.charWidth * window.screen.scale, window.height - (self.lineHeight * window.screen.scale), 0, window.screen.scale)
end

return Console
