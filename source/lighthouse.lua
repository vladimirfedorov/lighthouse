import "cannonball"
import "soundwaves"

local gfx = playdate.graphics

class("Lighthouse").extends(gfx.sprite)

function Lighthouse:init()
	local image = gfx.image.new("images/lighthouse")
	local x = screen.centerX + 8
	local y = screen.centerY - 5

	self.equipment = 0  --  0 light, 1 cannon, 2 horn
	self.angle = 0

	self.beamSprite = gfx.sprite.new()
	self.beamSprite.equipment = self.equipment
	self.beamSprite.beamAngle = self.angle
	self.beamSprite.beamSpread = 3

	function self.beamSprite:draw()
		gfx.pushContext()
		if self.equipment == 0 then
		    local x1 = screen.centerX + screen.radius * math.cos(math.rad(self.beamAngle - self.beamSpread))
		    local y1 = screen.centerY + screen.radius * math.sin(math.rad(self.beamAngle - self.beamSpread))
		    local x2 = screen.centerX + screen.radius * math.cos(math.rad(self.beamAngle + self.beamSpread))
		    local y2 = screen.centerY + screen.radius * math.sin(math.rad(self.beamAngle + self.beamSpread))
		    gfx.setPattern({ ~0x04, ~0x40, ~0x00, ~0x08, ~0x00, ~0x01, ~0x20, ~0x00 })
		    gfx.fillTriangle(screen.centerX, screen.centerY, x1, y1, x2, y2)
		    gfx.drawLine(screen.centerX, screen.centerY, x1, y1)
		    gfx.drawLine(screen.centerX, screen.centerY, x2, y2)
		elseif self.equipment == 1 then
		    local x = screen.centerX + screen.radius * math.cos(math.rad(self.beamAngle))
		    local y = screen.centerY + screen.radius * math.sin(math.rad(self.beamAngle))
			gfx.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
			gfx.drawLine(screen.centerX, screen.centerY, x, y)
		end
	    gfx.setColor(gfx.kColorBlack)
		gfx.popContext()
	end

	self:setImage(image)
	self:setCollideRect(0, 0, self:getSize())
	self:moveTo(x, y)
	self:add()

	self.beamSprite:setSize(screen.width, screen.height)
	self.beamSprite:moveTo(screen.centerX, screen.centerY)
	self.beamSprite:add()
end

function Lighthouse:equip(equipment)
	self.equipment = equipment
	self.beamSprite.equipment = equipment
	self.beamSprite:markDirty()
end

function Lighthouse:isOn()
	return self.equipment == 0
end

function Lighthouse:update()
	local crankChange = playdate.getCrankChange()
	if crankChange ~= 0 then
		self.angle = (self.angle + crankChange / 4) % 360
		self.beamSprite.beamAngle = self.angle
		self.beamSprite:markDirty()
	end
	if playdate.buttonJustPressed(playdate.kButtonA) then
		if self.equipment == 1 then
			playdate.sound.fileplayer.new("sounds/KickDrum"):play()
			shake(3)
			Cannonball(self.angle)
		elseif self.equipment == 2 then
			Soundwaves()
		end
	end
	if playdate.buttonJustPressed(playdate.kButtonB) then
		if self.equipment == -1 then
			return 
		end
		local divider = gameState.isHornAvailable and 3 or (gameState.isCannonAvailable and 2 or 1)
		self.equipment = (self.equipment + 1) % divider
		self:equip(self.equipment)
	end
end