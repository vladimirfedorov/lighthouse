local gfx = playdate.graphics

class('Shake').extends(gfx.sprite)

function Shake:init()
    self.shakeAmount = 0
    self:add()
end

function Shake:setShakeAmount(amount)
    self.shakeAmount = amount
end

function Shake:update()
    if self.shakeAmount > 0 then
        local shakeAngle = math.random() * math.pi * 2
        local shakeX = math.floor(math.cos(shakeAngle)) * self.shakeAmount
        local shakeY = math.floor(math.sin(shakeAngle)) * self.shakeAmount
        self.shakeAmount -= 1
        playdate.display.setOffset(shakeX, shakeY)
    else
        playdate.display.setOffset(0, 0)
    end
end