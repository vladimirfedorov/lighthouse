local gfx = playdate.graphics

class("Wave").extends(gfx.sprite)

function Wave:init(angle, distance)
	local size = 3

    self.angle = angle
    self.distance = distance
    self.counter = 0
    self.show = true
    self:setSize(size, size)
    local x = screen.centerX + distance * math.cos(math.rad(angle))
    local y = screen.centerY + distance * math.sin(math.rad(angle))

    self:moveTo(x, y)
    self:add()
end

function Wave:draw()
    gfx.pushContext()

    if self.show then
        gfx.setColor(gfx.kColorBlack)
    else 
        gfx.setColor(gfx.kColorBlack)
    end

    gfx.drawCircleAtPoint(1,1,1)

    gfx.popContext()
end

function Wave:update()
    self.counter += 1
    if self.counter % 60 == 0 then
        self.show = self.show and false or true
        self:markDirty()
    end
end