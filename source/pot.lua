local gfx = playdate.graphics

class("Pot").extends(gfx.sprite)

function Pot:init(angle)

    self.speed = 10
    self.frameCounter = 0
    self.globalOffset = 60

	local image = gfx.image.new("images/potbg")
    self:setImage(image)
    self:moveTo(screen.centerX, screen.centerY + self.globalOffset)
    self:add()

	self.layer0 = gfx.sprite.new()
	self.layer0.offset = -50
	self.layer0:setImage(gfx.image.new("images/pot0"))
    self.layer0:moveTo(screen.centerX, screen.centerY + self.layer0.offset + self.globalOffset)
    self.layer0:add()

	self.layer1 = gfx.sprite.new()
	self.layer1.offset = 140
	self.layer1:setImage(gfx.image.new("images/pot1"))
    self.layer1:moveTo(screen.centerX, screen.centerY + self.layer1.offset + self.globalOffset)
    self.layer1:add()

	self.layer2 = gfx.sprite.new()
	self.layer2.offset = 50
	self.layer2:setImage(gfx.image.new("images/pot2"))
    self.layer2:moveTo(screen.centerX, screen.centerY + self.layer2.offset + self.globalOffset)
    self.layer2:add()
end

function Pot:update() 
	if self.layer0.offset ~= 0 then
		self.layer0.offset += self.layer0.offset > 0 and -self.speed or self.speed
		self.layer0:moveTo(screen.centerX, screen.centerY + self.layer0.offset + self.globalOffset)
	end
	if self.layer1.offset ~= 0 then
		self.layer1.offset += self.layer1.offset > 0 and -self.speed or self.speed
		self.layer1:moveTo(screen.centerX, screen.centerY + self.layer1.offset + self.globalOffset)
	end
	if self.layer2.offset ~= 0 then
		self.layer2.offset += self.layer2.offset > 0 and -self.speed or self.speed
		self.layer2:moveTo(screen.centerX, screen.centerY + self.layer2.offset + self.globalOffset)
	end
end