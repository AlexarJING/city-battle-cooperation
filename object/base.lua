local base = class("base")
local id = 0
function base:init(...)
end

function base:create(...)
    self.data = {...}
    id = id + 1
    game.objects[id] = self
    self.id = id
    self.data.id = id
    self.data.tag = self.tag
    if net.server then net.server:sendToAll("create_obj",self.data) end
    print("create",self.id,self.tag)
end

function base:move()
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
    if self.destroyed then return end
    self.destroyed = true
    if self.aabb then
        game.world:remove(self)
    end
    game.objects[self.id] = nil
    if net.server then
        net.server:sendToAll("kill_obj",id)
    end
    print("destroy",self.id,self.tag)
end

return base