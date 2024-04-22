local gfx = playdate.graphics

class("Mermaids").extends(gfx.sprite)

function Mermaids:init(angle)
	local image = gfx.image.new("images/mermaids")

    local offset = 120
    local x = screen.centerX + offset * math.cos(math.rad(angle))
    local y = screen.centerY + offset * math.sin(math.rad(angle))

    self.angle = angle
    self.distance = offset
    self.x = x
    self.y = y

    self:setImage(image)
	self:setCollideRect(0, 0, self:getSize())
	self:moveTo(x, y)
	self:add()
end

function Mermaids:update() 

end