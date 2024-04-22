local gfx = playdate.graphics

class("Soundwaves").extends(gfx.sprite)

function Soundwaves:init()
    local x = screen.centerX
    local y = screen.centerY

    self.angle = angle
    self.distance = offset

    self.size = 64
    self.counter = 30

    self:setSize(self.size, self.size)
    self:moveTo(x, y)
    self:add()
end

function Soundwaves:draw()
    gfx.pushContext()
    local radii = { 10, 15, 20 }
    for _, baseRadius in ipairs(radii) do
        local numArcs = 4
        local arcLength = 360 / numArcs / 3
        local arcStep = 360 / numArcs
        for i = 1, numArcs do

            local arcStartOffset = 5 * math.sin(math.rad(self.counter * 10))
            local arcEndOffset   = 5 * math.sin(math.rad(self.counter * 10))
            local radiusOffset   = 2 * math.sin(math.rad(self.counter))

            local startAngle = (i - 1) * arcStep + arcStartOffset
            local endAngle   = (i - 1) * arcStep + arcLength + arcEndOffset
            local radius = baseRadius + 30 - self.counter

            if radius < self.size / 2 then
                gfx.drawArc(self.size / 2, self.size / 2, radius, startAngle, endAngle)
            end
        end
    end
    gfx.popContext()
end

function Soundwaves:update()
    if self.counter > 0 then
        self.counter -= 1
        self:markDirty()
    else
        spawnMermaids()
        -- spawnKraken()
        self:remove()
    end
end