-- Some helper functions
-- By V360

V360 = {}

function V360.line(x1, y1, x2, y2)
	love.graphics.line(math.floor(x1) + 0.5, math.floor(y1) + 0.5, math.floor(x2) + 0.5, math.floor(y2) + 0.5)
end

function V360.round(n)
	return math.floor(.5 + n)
end

function V360.sine(offset, cycle, height, center)
	height = height or 1
	center = center ~= false
	
	local result = math.sin(2 * math.pi * (offset / cycle))
	
	if center then
		-- From -height to height
		return result * height
	else
		-- From 0 to height
		local halfHeight = (height / 2)
		return halfHeight + (halfHeight * result)
	end
end

function V360.cosine(offset, cycle, height, center)
	height = height or 1
	center = center ~= false
	
	local result = math.cos(2 * math.pi * (offset / cycle))
	
	if center then
		-- From -height to height
		return result * height
	else
		-- From 0 to height
		local halfHeight = (height / 2)
		return halfHeight + (halfHeight * result)
	end
end

function V360.mid(a, b, c)
	return math.min(math.max(a, b), c)
end

function V360.sign(n)
	if n == 0 then return 0 end
	return n > 0 and 1 or -1
end

function V360.pointSquare(x1, y1, x2, y2, w2, h2)
	return x1 >= x2 and y1 >= y2 and x1 < x2 + w2 and y1 < y2 + h2
end

function V360.stringSplit(str, delimiter, max)
	local result = {}
	local current = 0
	local next = string.find(str, delimiter, current, true)
	
	if not next then return {str} end
	
	repeat
		table.insert(result, string.sub(str, current, next - 1))
		current = next + 1
		
		if max and #result > max then
			break
		end
		
		next = string.find(str, delimiter, current, true)
	until not next
	
	if not (max and #result > max) then
		table.insert(result, string.sub(str, current))
	end
	
	return result
end
