local game = class("game")

function game:init()
    self.world = bump.newWorld()
    self.map = Map(self.world,30,30,32)
    self.objects = {}
end

function game:update(dt)
    for id,obj in pairs(self.objects) do
        obj:update(dt)
    end
end

function game:draw()
    self.map:draw()
    for id,obj in pairs(self.objects) do
        obj:draw()
    end
    self.map:draw(true)
    love.graphics.setColor(255,0,0)
    if net.server then self.world:debugDraw() end
end

return game