local base = class("base")
local id = 0
function base:init(...)
end

function base:create(...)    
    if net.server then 
        self.data = {...}
        self.data.tag = self.tag
        id = id + 1
        game.objects[id] = self
        self.id = id
        self.data.id = id
        net.server:sendToAll("create_obj",self.data) 
        print("create",self.id,self.tag)
    end
end

function base:setID(id)
    self.id = id
    game.objects[id] = self
end

function base:syncMove()
    local data = {
        id = self.id,
        x = self.x,
        y = self.y,
        rot = self.rot
    }
    if net.server then
        net.server:sendToAll("move_obj",data)
    elseif net.client then
        net.client:send("need_move",data)
    end
end

function base:destroy()
    self.destroyed = true
    if self.aabb then
        game.world:remove(self)
    end
    if game.objects[self.id] then
        game.objects[self.id]  = nil
        if net.server then
            net.server:sendToAll("kill_obj",self.id)
        end
        print("destroy",self.id,self.tag)
    end
end

return base