local tank = class("tank",Base)
local tankAnimQuad = {{},{},{},{}}

for i = 0,7 do
    tankAnimQuad[1][i+1] = {0,i*16,16,16,0,0,31,15+i*16,0.1}
    tankAnimQuad[2][i+1] = {128,i*16,16,16,0,0,128+31,15+i*16,0.1}
    tankAnimQuad[3][i+1] = {0,i*16+128,16,16,0,0,31,15+i*16+128,0.1}
    tankAnimQuad[4][i+1] = {128,i*16+128,16,16,0,0,31+128,15+i*16+128,0.1}
end

tank.speed = 100
tank.fireCD = 0.2
tank.grade = 1
tank.tag = "tank"
tank.aabb = true

function tank:init(x,y,rot,scale,team,grade)
    self.x = x
    self.y = y
    self.ax = 8
    self.ay = 8
    self.rot = rot or 0
    self.team = team
    self.grade = grade or 1
    self.scale = scale or 1
    self.fireTimer = 0
    self.anim = Anim:new(res.texture,unpack(tankAnimQuad[self.team][self.grade]))
    game.world:add(self,
        self.x-self.ax*self.scale,
        self.y-self.ay*self.scale,
        self.scale*16,self.scale*16)
    self:create(x,y,rot,scale,team,grade)
end

function tank:control(dt)
    local down = love.keyboard.isDown
    local moved = true
    if down("w") then
        self.y = self.y - self.speed*dt
        self.rot = 0
    elseif down("s") then
        self.y = self.y + self.speed*dt
        self.rot = 2
    elseif down("a") then
        self.x = self.x - self.speed*dt
        self.rot = 3
    elseif down("d") then
        self.x = self.x + self.speed*dt
        self.rot = 1
    elseif down("space") then
        self:fire()
    else
        moved =false
    end
    return moved
end

function tank:fire(force)
    if self.fireTimer<0 or force then
        self.fireTimer = self.fireCD
 
        local x = self.x
        local y = self.y
        if self.rot == 0 then
            y = self.y - self.scale*8
        elseif self.rot == 1 then
            x = self.x + self.scale*8
        elseif self.rot == 2 then
            y = self.y + self.scale*8
        elseif self.rot == 3 then
            x = self.x - self.scale*8
        end
        if net.server then
            Bullet(x,y,self.rot,self.scale,self.team,self.grade)
        elseif net.client then
            net.client:send("need_fire",self.id)
        end
    end
end

function tank:damage()
    self.grade = self.grade -1 
    if self.grade<1 then
        self:destroy()
    end
end

function tank.collFilter(me,other)
    if other.tag == "brick" or other.tag == "water" or other.tag == "iron" 
        or other.tag == "base"or other.tag == "tank" or other.tag == "border" then
        return bump.Response_Slide
    else
        return bump.Response_Cross
    end
end

function tank:collision(cols)
    if self.destroyed then return end

    for i,col in ipairs(cols) do
		local other = col.other
        
    end
    return #cols>0
end

function tank:checkColl()
    if net.server then
        local x, y ,cols = game.world:move(self,
            self.x - self.ax*self.scale,
            self.y - self.ay*self.scale,self.collFilter)
        self.x, self.y = x + self.ax*self.scale, y + self.ay*self.scale
        return self:collision(cols)
    end
end

function tank:update(dt)
    if self.destroyed then return end
    self.fireTimer = self.fireTimer - dt
    local moved
    if self == game.player then
        moved = self:control(dt)
    end
    if moved then
        self:syncMove()
    end
end

function tank:syncMove(skipSync)
    local ifcoll = self:checkColl() 
    if (not skipSync) or ifcoll then
        self:move()
    end
end

function tank:draw()
    self.anim:update(love.timer.getDelta())
    self.anim:draw(self.x,self.y,self.rot*math.pi/2,self.scale,self.scale,self.ax,self.ay)
end

function tank:destroy()
    base.destroy(self)
    Ding(self.x,self.y,self.scale)
end
return tank