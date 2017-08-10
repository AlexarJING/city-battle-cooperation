local layout = {}


function layout:update()
    if suit.Button("server",1000,10,80,30).hit then
        net.client = nil
        net:serverInit()
        game = Game()
        game.map:random()
        love.window.setTitle("city battle- room master")
    end
    
    if suit.Button("client",1100,10,80,30).hit then
        net.server = nil
        net:clientInit()
        love.window.setTitle("city battle- room joiner")
        delay:new(0.5,function()net.client:send("need_init")end)
    end
    
    if suit.Button("addTank",1000,100,80,30).hit then
        if net.server then
            game.player = Tank(1000,300,0,3,1,1)
        elseif net.client then
            net.client:send("need_addTank")
        end
    end
end


return layout