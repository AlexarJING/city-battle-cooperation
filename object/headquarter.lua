local hq = class("headquarter",Base)
hq.aabb = true
hq.tag = "hq"
local hqQuad = love.graphics.newQuad(303, 31, 16, 16, 399, 255) 
local hqFallenQuad = love.graphics.newQuad(303+16, 31, 16, 16, 400, 256) 

hq.core = {{0,0},{0,1},
		   {1,0},{1,1}}
hq.inner = {
	{-1,-1},{0,-1},{1,-1},{2,-1},
	{-1,0},               {2, 0},
	{-1,1},               {2, 1},
	{-1,2}, {0,2}, {1,2}, {2, 2}	
}

hq.outer = {
	{-2,-2},{-1,-2},{0,-2},{1,-2},{2,-2},{3,-2},
	{-2,-1},               		  		 {3,-1},
	{-2, 0},               		  	 	 {3, 0},
	{-2, 1},					  		 {3, 1},
	{-2, 2},					  		 {3, 2},
	{-2, 3},{-1, 3},{0, 3},{1, 3},{2, 3},{3, 3},
}

function hq:init(tx,ty,team)
	self.tx = tx
	self.ty = ty
	self.team = team
	for i,tile in ipairs(self.core) do
		self:tryTile(tile[1]+tx,tile[2]+ty,0)
	end

	for i,tile in ipairs(self.inner) do
		self:tryTile(tile[1]+tx,tile[2]+ty,2)
	end

	for i,tile in ipairs(self.outer) do
		self:tryTile(tile[1]+tx,tile[2]+ty,2)
	end
	self.scale= game.map.size/8
	self.x = (self.tx-1)*self.scale*8
	self.y = (self.ty-1)*self.scale*8
	--print(self.tx,self.ty,self.scale)
	game.world:add(self,self.x,self.y,self.scale*16,self.scale*16)

	self:resetForceData()
	self:create(tx,ty,team)
end

function hq:resetForceData()
	game.forces[self.team] = {
            hq = self,
            reinforce = 30,
            score = 0
        }
end

function hq:tryTile(x,y,t)
	if game.map.tiles[x] and game.map.tiles[x][y] then
		game.map:setTile(x,y,t)
	end
end

function hq:update()

end

function hq:build()
	for i,tile in ipairs(self.inner) do
		self:tryTile(tile[1]+self.tx,tile[2]+self.ty,3)
	end

	for i,tile in ipairs(self.outer) do
		self:tryTile(tile[1]+self.tx,tile[2]+self.ty,0)
	end
end

function hq:draw()
	love.graphics.setColor(255, 255, 255, 255)
	if self.fallen then
		love.graphics.draw(res.texture,hqFallenQuad,
                        self.x,self.y,0,self.scale,self.scale)
	else
		love.graphics.draw(res.texture,hqQuad,
                        self.x,self.y,0,self.scale,self.scale)
	end
end


return hq