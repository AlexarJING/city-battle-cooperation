local tank = class("tank",Base)
local tankAnimQuad = {{},{},{},{}}

for i = 0,7 do
    tankAnimQuad[1][i+1] = {0,i*16,16,16,0,0,31,15+i*16,0.1}
    tankAnimQuad[2][i+1] = {128,i*16,16,16,0,0,128+31,15+i*16,0.1}
    tankAnimQuad[3][i+1] = {0,i*16+128,16,16,0,0,31,15+i*16+128,0.1}
    tankAnimQuad[4][i+1] = {128,i*16+128,16,16,0,0,31+128,15+i*16+128,0.1}
end

shellAnimQuad = {255,143,16,16,0,0,287,159,0.05,2}
tank.speed = 100
tank.fireCD = 0.2
tank.grade = 1
tank.tag = "tank"
tank.aabb = true
tank.shellCD = 5

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
    self.shellTimer = 0
    self.poweroffTimer = 0
    self.anim = Anim:new(res.texture,unpack(tankAnimQuad[self.team][self.grade]))
    self.shellAnim = Anim:new(res.texture,unpack(shellAnimQuad))
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

function tank:takeShell(time)
    self.shellTimer = time or self.shellCD
    self.inShell = true
    if net.server then net.server:sendToAll("shell",self.id) end
end

function tank:damage()
    if self.inShell then return end
    
    if self.grade==1 then
        self:destroy()
    else
        self:degrade()
    end
end

function tank:degrade()
    self.grade = self.grade -1 
    self.anim = Anim:new(res.texture,unpack(tankAnimQuad[self.team][self.grade]))
    if net.server then net.server:sendToAll("degrade",self.id) end
end

function tank:upgrade()
    self.grade = self.grade + 1
    if self.grade>8 then
        self.grade = 8
    end
    self.anim = Anim:new(res.texture,unpack(tankAnimQuad[self.team][self.grade]))
    if net.server then net.server:sendToAll("upgrade",self.id) end
end

function tank.collFilter(me,other)
    if other.tag == "brick" or other.tag == "water" or other.tag == "iron" 
        or other.tag == "hq" or other.tag == "tank" or other.tag == "border" then
        return bump.Response_Slide
    else
        return bump.Response_Cross
    end
end

function tank:collision(cols)
    if self.destroyed then return end
--[[
    for i,col in ipairs(cols) do
		local other = col.other
        
    end]]
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
    self.shellTimer =self.shellTimer - dt
    self.poweroffTimer =self.poweroffTimer - dt
    if self.shellTimer<0 then
        self.inShell = false
    end


    local moved
    if self == game.player and self.poweroffTimer<0 then
        moved = self:control(dt)
    end

    local colled = self:checkColl() 

    if moved or colled then
        self:syncMove()
    end
end

function tank:draw()
    love.graphics.setColor(255,255,255)
    self.anim:update(love.timer.getDelta())
    self.anim:draw(self.x,self.y,self.rot*math.pi/2,self.scale,self.scale,self.ax,self.ay)
    if self.inShell then
        self.shellAnim:update(love.timer.getDelta())
        local rnd = love.math.random()
        if rnd<0.33 then
            love.graphics.setColor(0,0,255)
        elseif rnd<0.66 then 
            love.graphics.setColor(255,0,0)
        else
            love.graphics.setColor(255,255,255)
        end
        self.shellAnim:draw(self.x,self.y,0,self.scale,self.scale,self.ax,self.ay)
    end
end

function tank:poweroff(time)
    self.poweroffTimer = time or 5
    if net.server then net.server:sendToAll("poweroff",self.id) end
end

function tank:destroy()
    Base.destroy(self)
    Ding(self.x,self.y,self.scale)
end
return tank