local bullet = class("bullet",Base)
local quad = love.graphics.newQuad(323,102,3,4,400,256)

bullet.speed = 400
bullet.aabb = true
bullet.tag = "bullet"
bullet.ax = 2
bullet.ay = 3
function bullet:init(x,y,rot,scale,team,grade)
    self.x = x
    self.y = y
    self.rot = rot
    self.scale = scale
    self.team = team
    self.grade = grade
    
    game.world:add(self,self.x-8*self.scale,self.y-8*self.scale,8*self.scale,8*self.scale)
    self:create(x,y,rot,scale,team,grade)
end

function bullet.collFilter(me,other)
    return bump.Response_Cross
end

function bullet:collision(cols)
    
    for i,col in ipairs(cols) do
		local other = col.other
        if self.destroyed then return end
        if not other.destroyed then
            if other.tag == "brick" then
               game.map:setTile(other.x,other.y,0)
               self:destroy()
            elseif other.tag == "iron" then
                if self.grade>4 then
                    game.map:setTile(other.x,other.y,0)
                end
                self:destroy()
            elseif other.tag == "tank" and other.team~=self.team then
                other:damage()
                self:destroy()
            elseif other.tag == "border" then
                self:destroy()
            end
        end
    end
end


function bullet:update(dt)
    if net.client then return end
    if self.destroyed then return end
    if self.rot == 0 then
        self.y = self.y - self.speed*dt
    elseif self.rot == 1 then
        self.x = self.x + self.speed*dt
    elseif self.rot == 2 then
        self.y = self.y + self.speed*dt
    elseif self.rot == 3 then
        self.x = self.x - self.speed*dt
    end
    self.x, self.y ,cols = game.world:move(self,self.x-5*self.scale,self.y-5*self.scale,self.collFilter)
    self.x, self.y = self.x +5*self.scale , self.y + 5*self.scale
    self:collision(cols)
    self:move()
end

function bullet:draw()
    love.graphics.setColor(255,255,255)
    love.graphics.draw(res.texture,quad,
        self.x,self.y,self.rot*math.pi/2,self.scale,self.scale,self.ax,self.ay)
end

function bullet:destroy()
    if self.destroyed then return end
    Base.destroy(self)
    Ding(self.x-self.scale*4,self.y-self.scale*4,self.scale,0.3)
end

return bullet