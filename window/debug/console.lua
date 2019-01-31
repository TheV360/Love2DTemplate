local Console = {
	enabled = false,
	
	width = 60,
	
	input = "",
	cursor = 1,
	camera = 1,
	cursorBlink = 0,
	
	-- select = false,
	-- selectFrom = -1,
	-- selectTo = -1,
	
	inputPrefix = ">> ",
	
	log = {
		"+-----------------------------+",
		"| ### ### ###  ## ### #   ### |",
		"| #   # # # #  #  # # #   ##  |",
		"| ### ### # # ##  ### ### ### |",
		"+-----------------------------+"
	},
	logMax = 24,
	
	history = {}, -- {"for i=1,#c.log do if type(c.log[i])=="string" then local p=i/(#c.log) c.log[i]={text=c.log[i],color={0.25*p,0.5*p,p}}end end"},
	historyMax = 32,
	historyNow = "",
	currHistory = 0,
	
	tab = {},
	currTab = 0,
	tabBefore = "",
	tabBeforeCursor = 0,
	tabMessage = false,
	emptyTab = true,
	
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
	
	tabStep = 4,
	
	validVariable = "[%a_][%a%d_]*",
	vagueIdentifier = "[%a_][%a%d_%.%:]*"
}

_debug_print_ = print

-- Hook to print function
print = function(...)
	_debug_print_(...)
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
		r = r .. string.rep(" ", 8 - #r % self.tabStep) .. tostring(t[i])
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

function Console:printSpecial(table)
	self:print()
	self.log[#self.log] = table
	
	_debug_print_(table.text)
end

function Console:addAtCursor(str)
	self.input = string.sub(self.input, 1, self.cursor - 1) .. str .. string.sub(self.input, self.cursor)
	self.cursor = self.cursor + #str
	self:moveCameraToCursor()
end

function Console:textinput(key)
	if not self.enabled then
		if key == "`" then
			self.enabled = true
		end
		return
	end
	
	self:hideTabMessage()
	
	self:addAtCursor(key)
	
	self:clearState()
end

function Console:keypressed(key)
	if not self.enabled then return end
	
	if key == "lshift" or key == "rshift"
	or key == "lctrl"  or key == "rctrl"
	or key == "lalt"   or key == "ralt"
	then return end
	
	self:hideTabMessage()
	
	if love.keyboard.isDown("lctrl", "rctrl") then
		if key == "x" then
			love.system.setClipboardText(self.input)
			self:clearInput()
		elseif key == "c" then
			love.system.setClipboardText(self.input)
		elseif key == "v" then
			self:addAtCursor(love.system.getClipboardText())
		elseif key == "z" then
			self:clearInput()
		else
			return
		end
	elseif love.keyboard.isDown("lshift", "rshift") then
		--[[if key == "up" then
		else]]if key == "tab" then
			self:tabCompletion(-1)
			return
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
		elseif key == "left" and self.cursor > 1 then
			self.cursor = self.cursor - 1
			self:moveCameraToCursor()
		elseif key == "right" and self.cursor < #self.input + 1 then
			self.cursor = self.cursor + 1
			self:moveCameraToCursor()
		elseif key == "home" then
			self.cursor = 1
			self:moveCameraToCursor()
		elseif key == "end" then
			self.cursor = #self.input + 1
			self:moveCameraToCursor()
		elseif key == "return" then
			self:runInput()
		elseif key == "delete" then
			if #self.input > 0 and self.cursor <= #self.input then
				self.input = string.sub(self.input, 1, self.cursor - 1) .. string.sub(self.input, self.cursor + 1)
				self:moveCameraToCursor()
			end
		elseif key == "backspace" then
			if #self.input > 0 and self.cursor > 1 then
				self.cursor = self.cursor - 1
				self.input = string.sub(self.input, 1, self.cursor - 1) .. string.sub(self.input, self.cursor + 1)
				self:moveCameraToCursor()
			end
		elseif key == "tab" then
			self:tabCompletion(1)
			return
		end
	end
	
	self:clearState()
end

function Console:hideTabMessage()
	if key ~= "tab" and self.tabMessage then
		self.log[#self.log] = nil
		self.tabMessage = false
	end
end

function Console:tabCompletion(dir)
	if self.currTab < 1 then
		-- Oof, we have to calculate the things
		self.tab = {}
		self.currTab = 0
		self.tabMessage = false
		
		-- So if you press tab here love.graphics.re|(), it only sees "love.graphics.re" [VALID] and not "love.graphics.re()" [INVALID]
		local inputCur = string.sub(self.input, 1, self.cursor - 1)
		local start, stop = inputCur:find(self.vagueIdentifier .. "$") -- grabs anything that looks like an identifier
		-- also must be at the end, hence the $
		
		local isValid, items
		
		-- We're supposed to have something.
		if #self.input > 0 and start then
			-- Yay, we found something that looks like an identifier!
			inputCur = string.sub(inputCur, start, stop)
			
			-- ...but is it really?
			isValid, items = self:isValidIdentifier(inputCur, true)
			
			-- It wasn't
			if not isValid then return end
		elseif self.emptyTab then
			-- It's alright to have nothing.
			items = {""}
		else
			return
		end
		
		-- It was!
		local i
		local tableTrace = _G -- _G contains itself oh gosh oh flip
		
		-- Trace down to the table we are in right now
		for i = 1, #items - 1 do
			tableTrace = tableTrace[items[i]]
			if (not tableTrace) or type(tableTrace) ~= "table" then return end -- Oh, turns out that doesn't exist, okay! :/
		end
		
		self.tabBeforeComponent = items[#items]
		
		-- Find something that looks like it!
		if #items[#items] > 0 then
			for i in pairs(tableTrace) do
				start = string.sub(i, 1, #items[#items]) -- Repurposed variable
				if start == items[#items] then
					table.insert(self.tab, string.sub(i, #items[#items] + 1))
				end
			end
		else
			for i in pairs(tableTrace) do
				table.insert(self.tab, i)
			end
		end
		
		-- If we didn't find anything, give up.
		if #self.tab < 1 then return end
		
		-- Alphabetize the stuff
		table.sort(self.tab)
		
		-- I think we've succeeded. Save the text you've added in preparation to add text
		-- also the cursor too. don't forget!
		self.tabBefore = self.input
		self.tabBeforeCursor = self.cursor
		
		-- Wraps properly.
		self.currTab = dir >= 0 and 0 or 1
	end
	
	-- Now, more general tasks
	self.currTab = ((self.currTab + dir - 1) % #self.tab) + 1
	
	-- Set the input to the base thing (DESCRIPTIVE COMMENTS)
	self.input = self.tabBefore
	self.cursor = self.tabBeforeCursor
	
	-- Add thing
	self:addAtCursor(self.tab[self.currTab])
	
	-- Fix
	self:moveCameraToCursor()
	
	-- Show tab status
	local msg = string.format("%" .. #tostring(#self.tab) .. "d / " .. #self.tab .. ": ", self.currTab)
	msg = msg .. self.tabBeforeComponent .. self.tab[self.currTab]
	
	if not self.tabMessage then
		self:print()
		self.log[#self.log] = {text = "", color = {1, 1, 1, 0.5}, noCamera = true}
		self.tabMessage = true
	end
	self.log[#self.log].text = msg
	
	-- Whoops
	self.cursorBlink = 0
end

function Console:runInput()
	local line = self.input
	
	self:clearInput()
	self.historyNow = nil
	self.currHistory = 0
	
	if line == "`" or line == "exit" or line == "quit" then self.enabled = false; return; end
	if line == "~" or line == "cls" or line == "clear" then self.log = {}; return; end
	if line == "?" or line == "help" then
		self:print("~~~ Help ~~~~~~~~~~~")
		self:print("`    - exit console ")
		self:print("cls  - clear console")
		self:print("help - display this ")
		self:print("keyb - key shortcuts")
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
	if line == "keyb" then
		self:print("~~~ Keyboard ~~~~~~~")
		self:print("up/dn - history     ")
		self:print("~~~~~~~~~~~~~~~~~~~~")
		self:print("ctrlZ - clear line  ")
		self:print("ctrlX - cut line    ")
		self:print("ctrlC - copy line   ")
		self:print("ctrlV - paste line  ")
		self:print("~~~~~~~~~~~~~~~~~~~~")
		self:print("tab   - autocomplete")
		self:print(" (shift goes back!) ")
		self:print("~~~~~~~~~~~~~~~~~~~~")
		
		return
	end
	
	-- Show line in console
	Console:printSpecial{text = self.inputPrefix .. line, color = {0.75, 0.875, 1}}
	
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
	self:moveCameraToCursor()
end

function Console:clearState()
	self.currTab = 0
	self.cursorBlink = 0
end

function Console:moveCameraToCursor()
	if self.camera                                      > self.cursor then self.camera = self.cursor                                        end
	if self.camera + self.width - #self.inputPrefix - 1 < self.cursor then self.camera = self.cursor - (self.width - #self.inputPrefix - 1) end
end

-- One variable
function Console:isValidVariable(str)
	return str:find(self.validVariable) and true or false
end

-- Multiple stuff
function Console:isValidIdentifier(str, openEnded)
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
	
	if openEnded and delCount == #vars then
		table.insert(vars, "")
	end
	
	return delCount + 1 == #vars, vars
end

function Console:update()
	if not self.enabled then return end
	self.cursorBlink = self.cursorBlink + 1
end

function Console:draw()
	if not self.enabled then return end
	
	local i, msg
	local bottomDist = (#self.log + 1) * (self.lineHeight * window.screen.scale)
	
	love.graphics.setColor(0.25, 0.25, 0.25, 0.5)
	love.graphics.rectangle("fill", 0, window.height - bottomDist, self.width * self.charWidth * window.screen.scale, bottomDist)
	
	love.graphics.setColor(1, 1, 1)
	for i = 1, #self.log do
		if type(self.log[i]) == "table" then
			msg = self.log[i].text
			love.graphics.setColor(self.log[i].color)
			
			if not self.log[i].noCamera then
				msg = string.sub(msg, self.camera, self.camera + self.width - 1)
			end
		else
			msg = self.log[i]
			love.graphics.setColor(1, 1, 1)
			
			msg = string.sub(msg, self.camera, self.camera + self.width - 1)
		end
		
		love.graphics.print(msg, 0, window.height - (bottomDist - (self.lineHeight * window.screen.scale * (i - 1))), 0, window.screen.scale)
	end
	
	love.graphics.setColor(0.5, 0.75, 1)
	msg = self.inputPrefix .. string.sub(self.input, self.camera, self.camera + self.width - #self.inputPrefix - 1)
	love.graphics.print(msg, 0, window.height - (self.lineHeight * window.screen.scale), 0, window.screen.scale)
	
	love.graphics.setColor(0.25, 0.5, 1, 0.5 + Util.cosine(self.cursorBlink, 90, 0.5))
	love.graphics.print("■", (self.cursor - self.camera + #self.inputPrefix) * self.charWidth * window.screen.scale, window.height - (self.lineHeight * window.screen.scale), 0, window.screen.scale)
end

return Console