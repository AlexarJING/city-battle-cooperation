path = string.sub(...,1,-5)
__TESTING = true
require (path.."lib/util")
class=require (path.."lib/middleclass")
gamestate= require (path.."lib/gamestate")
delay= require (path.."lib/delay")
tween = require (path.."lib/tween")
bump = require (path.."lib/bump")
Anim = require (path.."lib/animation")
bitser = require (path.."lib/bitser")
suit = require "lib/suit"

res = require "scr/resloader"
net = require "scr/net"
Base = require "object/base"
Tank = require "object/tank"
Bullet = require "object/bullet"
Ding = require "object/ding"
Map = require "object/map"
Game = require "scr/game"

function love.load()
    
    love.graphics.setBackgroundColor(50,50,150)
    gameState={}
    for _,name in ipairs(love.filesystem.getDirectoryItems(path.."scene")) do
        gameState[name:sub(1,-5)]=require(path.."scene."..name:sub(1,-5))
    end
    gamestate.registerEvents()
    gamestate.switch(gameState.test)
end

function love.update(dt)
    net:update()
    delay:update(dt)
end

function love.draw()
   suit.draw() 
end