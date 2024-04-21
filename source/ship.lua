Ship = {}

function Ship:new(angle)
    local ship = {}
    self.__index = self
    local radians = math.rad(angle)
    ship.x = 200 + 240 * math.cos(radians)
    ship.y = 120 + 240 * math.sin(radians)
    ship.speed = 1
    ship.size = 5
    ship.angle = angle
    ship.deviationAngle = 0
    ship.noticeTimer = 0
    ship.hasAppeared = false
    return setmetatable(ship, self)
end

-- Update ship's position
function Ship:update()
    local radians = math.rad(self.angle + self.deviationAngle)
    self.x = self.x - self.speed * math.cos(radians)
    self.y = self.y - self.speed * math.sin(radians)
    if self.x >= 0 and self.x < 400 and self.y >= 0 and self.y < 240 then
        self.hasAppeared = true
    end
end

-- Draw the ship
function Ship:draw()
    if self.hasAppeared then 
        if self.deviationAngle ~= 0 then
            playdate.graphics.fillCircleAtPoint(self.x, self.y, self.size)
        else 
            playdate.graphics.drawCircleAtPoint(self.x, self.y, self.size)
        end
    end
    
end

-- Collision
function Ship:isInCenter()
    local halfSide = 10
    return self.x > (200 - halfSide) and self.x < (200 + halfSide) and self.y > (120 - halfSide) and self.y < (120 + halfSide)
end

-- Out of view
function Ship:isOutsideScreen()
    if self.hasAppeared then
        return self.x < 0 or self.x >= 400 or self.y < 0 or self.y >= 240
    else
        return false
    end
end