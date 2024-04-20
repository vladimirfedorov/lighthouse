import "CoreLibs/graphics"
import "CoreLibs/crank"


local gfx = playdate.graphics
local squareSize = 40
local beamAngle = 0
local beamSpread = 3

function drawLighthouse()
    gfx.pushContext()
    gfx.setDrawOffset(200, 120)
    gfx.drawRect(-squareSize/2, -squareSize/2, squareSize, squareSize)
    gfx.popContext()
end

function drawBeam()
    local x2 = 200 + 240 * math.cos(math.rad(beamAngle - beamSpread))  -- Calculate endpoint of beam
    local y2 = 120 + 240 * math.sin(math.rad(beamAngle - beamSpread))
    gfx.drawLine(200, 120, x2, y2)

    local x2 = 200 + 240 * math.cos(math.rad(beamAngle + beamSpread))  -- Calculate endpoint of beam
    local y2 = 120 + 240 * math.sin(math.rad(beamAngle + beamSpread))
    gfx.drawLine(200, 120, x2, y2)
end

function updateWaves()
    gfx.pushContext()  -- Save the current graphics context

    -- Set a dither pattern for drawing
    -- Choose one of the predefined patterns or define your own
    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer4x4)

    local centerX, centerY = 200, 120  -- Center of the PlayDate screen
    local radii = {120, 160, 190}  -- Example radii for the circles

    for _, radius in ipairs(radii) do
        -- gfx.drawEllipse(centerX, centerY, radius, radius)
        gfx.drawCircleAtPoint(centerX, centerY, radius)
    end

    gfx.popContext()  -- Restore the previous graphics context
end

function updateBeamAngle()
    local crankChange = playdate.getCrankChange()
    beamAngle = (beamAngle + crankChange / 3) % 360
end


function playdate.start()
    drawLighthouse()
    drawBeam()
    updateWaves()
end

function playdate.update()
    updateBeamAngle()
    gfx.clear()
    drawLighthouse()
    drawBeam()
    updateWaves()
    gfx.sprite.update()
end
