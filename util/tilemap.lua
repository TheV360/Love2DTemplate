TileMap = Object:extend()

function TileMap:new(image, size)
	self.image = image
	self.batch = love.graphics.newSpriteBatch(self.image)
	
	self.size = size or 16
	self.width  = math.floor(self.image:getWidth()  / self.size)
	self.height = math.floor(self.image:getHeight() / self.size)
	
	self.quads = {}
	self.layers = {}
end

function TileMap:newLayer(width, height, index)
	if index then
		table.insert(self.layers, index, TileLayer(self, width, height))
	else
		table.insert(self.layers, TileLayer(self, width, height))
	end
end

function TileMap:makeQuad(tile)
	self.quads[tile] = love.graphics.newQuad(
		(           tile % self.width               ) * self.size,
		(math.floor(tile / self.width) % self.height) * self.size,
		self.size, self.size,
		self.image:getDimensions()
	)
end

function TileMap:releaseQuad(tile)
	self.quads[tile]:release()
	self.quads[tile] = nil
end

function TileMap:releaseUnusedQuads()
	-- TODO: inefficient garbage
	
	local used = {}
	for l = 1, #self.layers do
		for j = 1, #self.layers[l].tiles do
			for i = 1, #self.layers[l].tiles[j] do
				used[self.layers[l].tiles[j][i].tile] = true
			end
		end
	end
	
	for i, q in pairs(self.quads) do
		if not used[i] then
			self:releaseQuad(i)
		end
	end
end

function TileMap:draw(x, y)
	local _, v
	
	self.batch:clear()
	for _, v in pairs(self.layers) do
		v:draw()
	end
	self.batch:flush()
	
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.batch, x or 0, y or 0)
end

return TileMap
