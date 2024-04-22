import "globals"

local gfx = playdate.graphics

class("Menu").extends(gfx.sprite)

function Menu:init(done)
	local dialogImage = gfx.image.new("images/dialog-base")
	local w, h = dialogImage:getSize()
	local x = screen.centerX
	local y = screen.centerY
	local textPadding = 20

	self.text = text
	self.done = done

	local menuOptions = "Story\nFree Play"
	self.optionsCount = 2
	self.selectedOption = 0

	self.textSprite = gfx.sprite.new()
	self.textSprite.currentText = ""

	function self.textSprite:draw()
		gfx.pushContext()
		gfx.setColor(gfx.kColorBlack)
		gfx.drawTextInRect(menuOptions, 0, 0, 200, 200)
		gfx.popContext()
	end

	self:setImage(dialogImage)
	self:moveTo(x, y)
	self:add()
	
	self.textSprite:setSize(w - textPadding * 2, h - textPadding * 2)
	self.textSprite:moveTo(x + 10, y)
	self.textSprite:add()

	self.selectorSprite = gfx.sprite.new()
	self.selectorSprite:setSize(10, 10)
	function self.selectorSprite:draw()
		gfx.pushContext()
		gfx.fillTriangle(0, 0, 10, 5, 0, 10)
		gfx.popContext()
	end
	self.selectorSprite:add()
end

function Menu:update()
	if playdate.buttonJustPressed(playdate.kButtonDown) then
		self.selectedOption += 1
		if self.selectedOption >= self.optionsCount then
			self.selectedOption = self.optionsCount - 1
		else
			playdate.sound.fileplayer.new("sounds/clav"):play()
		end
	end
	if playdate.buttonJustPressed(playdate.kButtonUp) then
		self.selectedOption -= 1
		if self.selectedOption < 0 then
			self.selectedOption = 0
		else
			playdate.sound.fileplayer.new("sounds/clav"):play()
		end
	end
	local x = (screen.width - self.textSprite.width) / 2
	local y = (screen.height - self.textSprite.height) / 2 + 10 + self.selectedOption * 20
	self.selectorSprite:moveTo(x, y)

	if playdate.buttonJustPressed(playdate.kButtonA) then
		playdate.sound.fileplayer.new("sounds/clav"):play()
		self.done(self.selectedOption)
		self:remove()
	end
end