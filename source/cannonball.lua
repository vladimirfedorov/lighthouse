import "kraken"
import "mermaids"
import "wreckage"

local gfx = playdate.graphics

class("Cannonball").extends(gfx.sprite)

function Cannonball:init(angle)
	local size = 3
    local image = gfx.image.new(size * 2, size * 2)
    
    gfx.pushContext(image)
    gfx.fillCircleAtPoint(size, size, size)
    gfx.popContext()
    self:setImage(image)

    local offset = 8
    local x = screen.width / 2 + offset * math.cos(math.rad(angle))
    local y = screen.height / 2 + offset * math.sin(math.rad(angle))

    self.angle = angle
    self.distance = offset

    self:setCollideRect(0, 0, self:getSize())
    self.speed = 5
    self:moveTo(x, y)
    self:add()
end

function Cannonball:collisionResponse(other)
    return gfx.sprite.kCollisionTypeOverlap
end

function Cannonball:update() 
	self.distance += self.speed
	self.speed -= 0.08
	local x = screen.width / 2 + self.distance * math.cos(math.rad(self.angle))
	local y = screen.height / 2 + self.distance * math.sin(math.rad(self.angle))
	if x < 0 or x > screen.width or y < 0 or y > screen.height then
		self:remove()
	end
	if self.speed < 2 then
		self:remove()
		Wreckage(x, y, 3)
	end
	local actualX, actualY, collisions, length = self:moveWithCollisions(x, y)
	if length > 0 then
        for index, collision in ipairs(collisions) do
            local collidedObject = collision['other']
            if collidedObject:isa(Kraken) then
                collidedObject:remove()                
		        self:remove()
		        kraken = nil
		    elseif collidedObject:isa(Mermaids) then
                collidedObject:remove()                
		        self:remove()
		        mermaids = nil
            end
        end
    end
end