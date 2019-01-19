Watch = {}

function Watch.new(keyTable, checkFunction)
	local _, value
	local watch = {
		downTime = {},
		down = {},
		press = {},
		release = {},
		
		keys = keyTable,
		check = checkFunction
	}
	
	for _, value in ipairs(self.keys) do
		self.downTime[value] = 0
		self.down[value]     = false
		self.press[value]    = false
		self.release[value]  = false
	end
	
	function watch:update()
		local index, value, _
		
		for _, value in ipairs(self.keys) do
			self.down[value] = self.check(value)
			self.press[value] = false
			self.release[value] = false
			
			if self.down[value] then
				if self.downTime[value] == 0 then
					self.press[value] = true
				end
				self.downTime[value] = self.downTime[value] + 1
			else
				if self.downTime[value] > 0 then
					self.release[value] = true
				end
				self.downTime[value] = 0
			end
		end
	end
	
	return watch
end
