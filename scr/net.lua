local sock = require "lib/sock"

local net = {}

function net:serverInit()
    self.server = sock.newServer()
    self.clients = {}
    self.server:on("connect", function(data,client)
        self.clients[client.connection] = self.clients[client.connection] or {}
    end)

    self.server:on("need_init",function(data,client)
        local data = {}
        for id,obj in pairs(game.objects)do
            data[id] = obj.data
        end
        client:send("reply_init",{obj = data, map = game.map.tiles})
    end)

    self.server:on("need_addTank",function(data,client)
        local tank = Tank(1000,500,0,3,2,1)
        delay:new(1,function() client:send("your_tank",tank.id) end)
    end)

    self.server:on("need_fire",function(data,client)
        game.objects[data]:fire(true)
    end)

    self.server:on("need_move",function(data,client)
        local obj = game.objects[data.id]
        obj.x,obj.y,obj.rot = data.x,data.y,data.rot
        obj:syncMove(true)
    end)
end

function net:clientInit()
    self.client = sock.newClient() 
    self.client:connect()
    self.client:on("connect", function(data)
       self.connected = true
       print("ok")
    end)

    self.client:on("reply_init",function(data)
        print("sync")
        for id,objData in pairs(data.obj) do
            local obj
            if objData.tag == "tank" then
                obj=Tank(unpack(objData))
            elseif objData.tag == "bullet" then
                obj=Bullet(unpack(objData))
            elseif objData.tag == "ding" then
                obj=Ding(unpack(objData))
            end
            obj.id = objData.id
        end

        game.map:setData(data.map)
    end)


    self.client:on("create_obj",function(data)
        local obj 
        if data.tag == "tank" then
            obj=Tank(unpack(data))
        elseif data.tag == "bullet" then
            obj=Bullet(unpack(data))
        elseif data.tag == "ding" then
            obj=Ding(unpack(data))
        end
        obj.id = data.id
    end)
    
    self.client:on("move_obj",function(data)
        local obj = game.objects[data.id]
        if not obj then 
            print("ERRPR:NOT EXIST",data,data.id)
            return
        end
        obj.x,obj.y,obj.rot = data.x,data.y,data.rot
    end)

    self.client:on("kill_obj",function(data)
        game.objects[data] = nil
    end)
    
    self.client:on("set_tile",function(data)
        game.map:setTile(unpack(data))
    end)

    self.client:on("your_tank",function(data)
        game.player = game.objects[data]
        print("my tank here",data)
    end)
end

function net:serverUpdate(dt)
    self.server:update()
end

function net:clientUpdate(dt)
    self.client:update()
end

function net:init(game,s)
    self.game = game 
    if s then self:serverInit() 
    else self:clientInit() end
end


function net:update()
   if net.server then net:serverUpdate() end
   if net.client then net:clientUpdate() end
end

return net