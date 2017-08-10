local res = {}
love.graphics.setDefaultFilter("nearest","nearest")
local imagedata = love.image.newImageData("res/tiles.png")
imagedata:mapPixel(function(x,y,r,g,b,a)
    if r == 0 and g == 0 and b <= 1 then
        a = 0
    end
    return r,g,b,a
end)
res.texture = love.graphics.newImage(imagedata)


return res