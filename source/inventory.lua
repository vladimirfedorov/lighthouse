local gfx = playdate.graphics

class("Inventory").extends(gfx.sprite)

function Inventory:init(angle)

	local image = gfx.image.new("images/inventory")
    self:setImage(image)
    self:moveTo(screen.width - self.width / 2, self.height / 2)
    self:add()

    local w ,h = self:getSize()

    self.width = w
    self.height = h

	self.light = gfx.sprite.new()
	self.light:setImage(gfx.image.new("images/lamp"))
    self.light:moveTo(screen.width - self.height / 2, self.height / 2)
    self.light:add()

	self.cannon = gfx.sprite.new()
	self.cannon:setImage(gfx.image.new("images/cannon"))
    self.cannon:moveTo(screen.width - self.height / 2, self.height / 2)
    self.cannon:add()

	self.horn = gfx.sprite.new()
	self.horn:setImage(gfx.image.new("images/horn"))
    self.horn:moveTo(screen.width - self.height / 2, self.height / 2)
    self.horn:add()
end

function Inventory:update() 
	isSelfVisible = gameState.isCannonAvailable
	isLightVisible = (lighthouse.equipment == 0) and isSelfVisible
	isCannonVisible = (lighthouse.equipment == 1) and isSelfVisible
	isHornVisible = (lighthouse.equipment == 2) and isSelfVisible

	if isSelfVisible ~= self:isVisible() then
		self:setVisible(isSelfVisible)
	end

	if isLightVisible ~= self.light:isVisible() or isCannonVisible ~= self.cannon:isVisible() or isHornVisible ~= self.horn:isVisible() then
		self.light:setVisible(isLightVisible)
		self.cannon:setVisible(isCannonVisible)
		self.horn:setVisible(isHornVisible)
	end

end