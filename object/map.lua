local map = class("map")
local tileType = {"forest","brick","iron","water","ice"}
local tileQuad = {
    love.graphics.newQuad(264,72,8,8,400,256),
    love.graphics.newQuad(256,64,8,8,400,256),
    love.graphics.newQuad(256,72,8,8,400,256),
    love.graphics.newQuad(256,80,8,8,400,256),
    love.graphics.newQuad(272,72,8,8,400,256),
}

function map:setTile(x,y,t)
    self.tiles[x] = self.tiles[x] or {}
    local tile = self.tiles[x][y]
    if tile then
        tile.type = t
        tile.tag = tileType[t]
    else
        tile = {type = t,tag = tileType[t],x= x,y=y}
        self.world:add(tile,(x-1)*self.size,(y-1)*self.size,self.size,self.size)
    end
    self.tiles[x][y] = tile
    if net.server then net.server:sendToAll("set_tile",{x,y,t}) end
end

function map:init(world,w,h,size)
    self.w = w
    self.h = h
    self.size = size or 32
    self.world = world
    self.tiles = {}
    for x = 1, w do
        for y = 1, h do
           self:setTile(x,y,0)
        end
    end
    if net.server then net.server:sendToAll("reset_map",{w,h,size}) end
end

function map:setData(data)
    for x = 1, self.w do
        for y = 1, self.h do
           self:setTile(x,y,data[x][y].type)
        end
    end
end

function map:random()
    for x = 1, self.w, 2 do
        for y = 1, self.h,2 do
           local t = love.math.random(0,5)
           self:setTile(x+1,y,t)
           self:setTile(x,y,t)
           self:setTile(x+1,y+1,t)
           self:setTile(x,y+1,t)
        end
    end
end

function map:update(dt)
end

function map:draw(forest)
    love.graphics.setColor(255,255,255)
    for x = 1, self.w  do
        for y = 1, self.h do
            local tile = self.tiles[x][y].type
            if (tile==1 and forest) or (tile~=0 and not forest) then
                love.graphics.draw(res.texture,tileQuad[tile],
                        (x-1)*self.size,(y-1)*self.size,0,self.size/8,self.size/8)
            end
        end
    end
end

return map