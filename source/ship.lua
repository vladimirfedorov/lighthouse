import "kraken"
import "mermaids"
import "lighthouse"
import "cannonball"
import "globals"
import "wreckage"

local gfx = playdate.graphics

class("Ship").extends(gfx.sprite)

function Ship:init(angle)
	local size = 18
    local offset = screen.radius

    self:setSize(size, size)
    local x = screen.centerX + offset * math.cos(math.rad(angle))
    local y = screen.centerY + offset * math.sin(math.rad(angle))

    self.size = size
    self.angle = angle
    self.deviationAngle = 0
    self.didAppear = false
    self.noticeTimer = 0

    self:setCollideRect(0, 0, self:getSize())
    self.speed = 0.5
    self:moveTo(x, y)
    self:add()
end

function Ship:draw()
    gfx.pushContext()
    local x = self.size / 2
    local y = self.size / 2
    gfx.fillCircleAtPoint(x, y, 5)

    if self.deviationAngle > 0 and self.deviationAngle < 45 then
        local lines = 6
        for i = 0, 360, 360 / lines do
            local x1 = x + 6 * math.cos(math.rad(self.angle + i))
            local y1 = y + 6 * math.sin(math.rad(self.angle + i))
            local x2 = x + 9 * math.cos(math.rad(self.angle + i))
            local y2 = y + 9 * math.sin(math.rad(self.angle + i))
            gfx.drawLine(x1, y1, x2, y2)
        end
    end

    gfx.popContext()
end

function Ship:collisionResponse(other)
    return gfx.sprite.kCollisionTypeOverlap
end

function Ship:update()
    if gameState.isPaused then
        return
    end

    if lighthouse ~= nil and lighthouse:isOn() and math.abs(lighthouse.angle - self.angle) < 6 and self.didAppear then
        if self.noticeTimer < 15 then
            self.noticeTimer += 1
        end
    end

    if self.noticeTimer >= 15 and self.deviationAngle == 0 then
        didAlert()
    end

    if self.noticeTimer >= 15 and self.deviationAngle < 45 then
        self.deviationAngle += 3
        self:markDirty()
    end

    if mermaids ~= nil then
        local deltaX = self.x - mermaids.x
        local deltaY = self.y - mermaids.y
        local angle = math.deg(math.atan2(deltaY, deltaX))
        self.deviationAngle = 360
        self.angle = angle
    elseif self.deviationAngle == 360 then
        self.deviationAngle = 0
    end

	local x = self.x - self.speed * math.cos(math.rad(self.angle + self.deviationAngle))
	local y = self.y - self.speed * math.sin(math.rad(self.angle + self.deviationAngle))
    if x > 0 and x < screen.width and y > 0 and y < screen.height then
        self.didAppear = true
    end
	if (x < 0 or x > screen.width or y < 0 or y > screen.height) and self.didAppear then
		self:remove()
        didSaveShip()
	end
	local actualX, actualY, collisions, length = self:moveWithCollisions(x, y)
	if length > 0 then
        for index, collision in ipairs(collisions) do
            local collidedObject = collision['other']
            if collidedObject:isa(Kraken) or collidedObject:isa(Mermaids) then
                self:remove()
                didCrashShip()
                Wreckage(actualX, actualY, 5)
            elseif collidedObject:isa(Lighthouse) then
                shake(5)
                self:remove()
                didCrashShip()
                Wreckage(actualX, actualY, 5)
            elseif collidedObject:isa(Cannonball) then
                collidedObject:remove()
                self:remove()
                didCrashShip()
                Wreckage(actualX, actualY, 5)
            end
        end
    end
end