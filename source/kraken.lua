local gfx = playdate.graphics

class("Kraken").extends(gfx.sprite)

function Kraken:init(angle)
	local image = gfx.image.new("images/kraken")

    local offset = 80
    local x = screen.centerX + offset * math.cos(math.rad(angle))
    local y = screen.centerY + offset * math.sin(math.rad(angle))

    self.angle = angle
    self.distance = offset

	self:setImage(image)
    self:setCollideRect(0, 0, self:getSize())
	self:moveTo(x, y)
	self:add()
end

function Kraken:update() 

end