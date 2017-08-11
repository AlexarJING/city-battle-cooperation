local item = class("item",Base)
local itemQuad = {}
for i = 0,6 do
	itemQuad[i+1] = love.graphics.newQuad(255+16*i, 111, 16, 16, 400, 256)
end
local itemType = {
	"shell","timer","build","upgrade","boom","reinforce","gearup"
}
item.tag = "item"
item.aabb = true

function item:init(x,y,scale,type)
	self.x = x
	self.y = y
	self.type = type or love.math.random(1,7)
	self.ax = 8
    self.ay = 8
	self.scale = scale or 1
    game.world:add(self,
        self.x-self.ax*self.scale,
        self.y-self.ay*self.scale,
        self.scale*16,self.scale*16)
    self:create(x,y,scale,self.type)
end


function item.collFilter(me,other)
    return bump.Response_Cross
end

function item:collision(cols)
    
    for i,col in ipairs(cols) do
		local other = col.other
        if self.destroyed then return end
        if not other.destroyed then
            if other.tag == "tank" then
            	self.collFunc[self.type](other)
            	self:destroy()
            end
        end
    end
end

function item:checkColl()
    local x, y ,cols = game.world:move(self,
        self.x - self.ax*self.scale,
        self.y - self.ay*self.scale,self.collFilter)
    self.x, self.y = x + self.ax*self.scale, y + self.ay*self.scale
    return self:collision(cols)
end

function item:update()
	if net.server then
		self:checkColl()
	end
end

function item:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(res.texture,itemQuad[self.type],
		self.x,self.y,0,self.scale,self.scale,self.ax,self.ay)
end

local function upgrade(tank)
	tank:upgrade()
end

local function shell(tank)
	tank:takeShell()
end

local function timer(tank)
	for id, obj in pairs(game.objects) do
		if obj.tag == "tank" and obj.team~=tank.team then
			obj:poweroff(5)
		end
	end
end

local function build(tank)
	game.forces[tank.team].hq:build()
end

local function boom(tank)
	for id, obj in pairs(game.objects) do
		if obj.tag == "tank" and obj.team~=tank.team then
			obj:damage()
		end
	end
end

local function reinforce(tank)
	game.forces[tank.team].reinforce = game.forces[tank.team].reinforce + 1
	net.server:sendToAll("reinforce",tank.team)
end

local function gearup(tank)
	for id, obj in pairs(game.objects) do
		if obj.tag == "tank" and obj.team==tank.team then
			obj:upgrade()
		end
	end
end

--[[
local itemType = {
	"shell","timer","build","upgrade","boom","reinforce","gearup"
}]]

item.collFunc = {shell,timer,build,upgrade,boom,reinforce,gearup}

return item