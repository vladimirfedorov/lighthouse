import "globals"

local gfx = playdate.graphics

class("Dialog").extends(gfx.sprite)

function Dialog:init(text, variant, done)
	local dialogImage = gfx.image.new("images/dialog-" .. variant)
	local w, h = dialogImage:getSize()
	local x = screen.width / 2
	local y = screen.height / 2
	local textPadding = 20

	self.text = text
	self.done = done

	self.textSprite = gfx.sprite.new()
	self.textSprite.currentText = ""
	self.updateCounter = 0

	function self.textSprite:draw()
		gfx.pushContext()
		gfx.setColor(gfx.kColorBlack)
		gfx.drawTextInRect(self.currentText, 0, 0, 200, 200)
		gfx.popContext()
	end

	self:setImage(dialogImage)
	self:moveTo(x, y)
	self:add()
	
	self.textSprite:setSize(w - textPadding * 2, h - textPadding * 2)
	self.textSprite:moveTo(x, y)
	self.textSprite:add()
end

function Dialog:update()
	if #self.textSprite.currentText < #self.text and self.updateCounter % 1 == 0 then
		self.textSprite.currentText = string.sub(self.text, 1, #self.textSprite.currentText + 1)
		self.textSprite:markDirty()
	end
	if playdate.buttonJustPressed(playdate.kButtonA) then
		self.textSprite:remove()
		if self.done ~= nil then
			playdate.sound.fileplayer.new("sounds/clav"):play()
			self.done()
		end
		self:remove()
	end
	self.updateCounter += 1
end