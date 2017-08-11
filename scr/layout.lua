local layout = {}


function layout:update()
    if suit.Button("server",10,500,80,30).hit then
        net.client = nil
        net:serverInit()
        game = Game()
        game.map:random()
        game.team = 1
        game.hq = HQ(15,1,game.team)
        --game.hq:build()
        love.window.setTitle("city battle- room master")
        love.window.setPosition(100,100)
    end
    
    if suit.Button("client",110,500,80,30).hit then
        net.server = nil
        net:clientInit()
        game.team = 2
        --game.hq = HQ(15,29,game.team)

        love.window.setTitle("city battle- room joiner")
        love.window.setPosition(1280-550,100)
        delay:new(0.5,function()
            net.client:send("need_init")
            net.client:send("need_HQ",{15,29,game.team})
        end)
    end
    
    if suit.Button("addTank",10,550,80,30).hit then
        if net.server then
            game.player = Tank(500,500,0,2,game.team,1)
        elseif net.client then
            net.client:send("need_tank",{550,500,0,2,game.team,1})
        end
    end
    if suit.Button("addItem",110,550,80,30).hit then
        if net.server then
            Item(500,400,2)
        end
    end
end


return layout