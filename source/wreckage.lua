local gfx = playdate.graphics

class("Wreckage").extends(gfx.sprite)

function Wreckage:init(x, y, ballSize)

    print(x, y)

    self.x = x
    self.y = y
    self.ballSize = ballSize
    self.size = 30
    self.counter = 30

    self:setSize(self.size, self.size)
    self:moveTo(x, y)
    self:add()
end

function Wreckage:draw()
    gfx.pushContext()
    local minRadius = 0
    for i = 1, 3 do
        local radius = minRadius + i * 4 + ((30 - self.counter) / 10)
        print(radius)
        gfx.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
        gfx.drawCircleAtPoint(self.size / 2, self.size / 2, radius)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillCircleAtPoint(self.size / 2, self.size / 2, self.ballSize * (self.counter / 30))
    end
    gfx.popContext()
end

function Wreckage:update()
    if self.counter > 0 then
        self.counter -= 1
        self:markDirty()
    else
        self:remove()
    end
end