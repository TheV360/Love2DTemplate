function setup()
end

function update()
end

function draw()
	for j = 0, 127 do
		for i = 0, 127 do
			love.graphics.setColor(
				0, bit.bxor(i, j) / 128, bit.bxor(math.max(0, 63 - j), i) / 128
			)
			
			love.graphics.points(i, j)
		end
	end
end
