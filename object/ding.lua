local ding = class("ding",Base)
local dingQuad = {256,128,16,16,0,0,304,176,0.1,3}

ding.tag = "ding"

function ding:init(x,y,scale,last)
    self.x = x
    self.y = y
    self.scale = scale
    self.last = last or 0.5
    self.anim = Anim:new(res.texture,unpack(dingQuad))
    self:create(x,y,scale,last)
end

function ding:update(dt)
    if net.client then return end
    if self.destroyed then return end
    self.last = self.last - dt
    if self.last<0 then
        self:destroy()
    end
end

function ding:draw()
    self.anim:update(love.timer.getDelta())
    self.anim:draw(self.x,self.y,0,self.scale,self.scale,8,8)
end

return ding