-- Some helper functions
-- By V360

function line(x1, y1, x2, y2)
	love.graphics.line(math.floor(x1) + 0.5, math.floor(y1) + 0.5, math.floor(x2) + 0.5, math.floor(y2) + 0.5)
end

function round(n)
	return math.floor(.5 + n)
end

function sine(offset, cycle, height, center)
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

function cosine(offset, cycle, height, center)
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

function mid(a, b, c)
	return math.min(math.max(a, b), c)
end

function sign(n)
	if n == 0 then return 0 end
	return n > 0 and 1 or -1
end

function pointSquare(x1, y1, x2, y2, w2, h2)
	return x1 >= x2 and y1 >= y2 and x1 < x2 + w2 and y1 < y2 + h2
end