local console = {
	enabled = false,
	
	input = "",
	cursor = 1,
	
	log = {"-- Console Log --"},
	max = 16,
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
		self:printLine(t[i])
	end
end

function console:printLine(l)
	self.log[#self.log] = tostring(l)
	
	-- "Scroll"
	if #self.log > self.max then
		table.remove(self.log, 1)
	end
end

function console:update()
	if not self.enabled then return end
	
end

function console:draw()
	if not self.enabled then return end
	
end

return console
