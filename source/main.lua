import "CoreLibs/graphics"
import "CoreLibs/crank"

local gfx = playdate.graphics
local squareSize = 20
local beamAngle = 0
local beamSpread = 3
local frameNumber = 0
local frameCount = 0
local startTime = playdate.getCurrentTimeMilliseconds()
local lastFPS = 0  -- Store the last calculated FPS

local ship = {
    x = 0,
    y = 0,
    speed = 1,
    size = 5,
    angle = 0,
    deviationAngle = 0,
    noticeTimer = 0
}


local centerX, centerY = 200, 120
local initialDistance = 140

function initShip(angle)
    ship.angle = angle
    ship.deviationAngle = 0
    ship.noticeTimer = 0
    local radians = math.rad(ship.angle)
    ship.x = centerX + initialDistance * math.cos(radians)
    ship.y = centerY + initialDistance * math.sin(radians)
    ship.speed = 1
    -- print(string.format("Ship: %i %i", ship.x, ship.y))
end

function angleFromCenterToPoint(x, y)
    local deltaX = x - centerX
    local deltaY = y - centerY
    return math.deg(math.atan2(deltaY, deltaX))  -- Convert radians to degrees
end

function updateAndDrawShip()
    if ship.x < 0 or ship.x > 400 or ship.y < 0 or ship.y > 240 then
        initShip(math.random() * 360)
    end

    if ((ship.x - 200)^2 + (ship.y - 120)^2) <= 10^2 then
        initShip(math.random() * 360)
    end

    gfx.fillCircleAtPoint(ship.x, ship.y, ship.size)

    local angleDifference = ship.angle - beamAngle
    if ship.deviationAngle == 0 and math.abs(angleDifference) <= 10 then
       if ship.noticeTimer >= 15 then
            ship.deviationAngle = angleDifference > 0 and 30 or -30
       else
            ship.noticeTimer = ship.noticeTimer + 1
       end
    end
    local radians = math.rad(ship.angle + ship.deviationAngle)
    ship.x = ship.x - ship.speed * math.cos(radians)
    ship.y = ship.y - ship.speed * math.sin(radians)
end

function drawLighthouse()
    gfx.pushContext()
    gfx.setDrawOffset(200, 120)
    gfx.drawRect(-squareSize/2, -squareSize/2, squareSize, squareSize)
    gfx.popContext()
end

function drawBeam()
    local x1 = 200 + 240 * math.cos(math.rad(beamAngle - beamSpread)) 
    local y1 = 120 + 240 * math.sin(math.rad(beamAngle - beamSpread))
    local x2 = 200 + 240 * math.cos(math.rad(beamAngle + beamSpread)) 
    local y2 = 120 + 240 * math.sin(math.rad(beamAngle + beamSpread))

    -- gfx.setColor(gfx.kColorWhite)
    -- gfx.setColor(gfx.kColorBlack)
    -- gfx.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
    gfx.setPattern({ ~0x04, ~0x40, ~0x00, ~0x08, ~0x00, ~0x01, ~0x20, ~0x00 })
    gfx.fillTriangle(centerX, centerY, x1, y1, x2, y2)
    gfx.drawLine(200, 120, x1, y1)
    gfx.drawLine(200, 120, x2, y2)
    gfx.setColor(gfx.kColorBlack)
end

function drawRay(angle, color)
    local x = 200 + 240 * math.cos(math.rad(angle))
    local y = 120 + 240 * math.sin(math.rad(angle))
    gfx.drawLine(200, 120, x, y)
end

function updateFPS()
    frameCount = frameCount + 1
    local currentTime = playdate.getCurrentTimeMilliseconds()
    local elapsedTime = currentTime - startTime

    if elapsedTime >= 1000 then  -- Calculate FPS once every second
        lastFPS = frameCount
        frameCount = 0
        startTime = currentTime
    end

    -- Display the FPS
    gfx.setFont(gfx.font.kSystemFontBold)
    gfx.drawText(string.format("FPS: %d", lastFPS), 10, 10)
end

function updateWaves()
    -- gfx.pushContext()  -- Save the current graphics context

    -- -- Set a dither pattern for drawing
    -- -- Choose one of the predefined patterns or define your own
    -- gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer4x4)

    -- local centerX, centerY = 200, 120  -- Center of the PlayDate screen
    -- local radii = {120, 160, 190}  -- Example radii for the circles

    -- for _, radius in ipairs(radii) do
    --     -- gfx.drawEllipse(centerX, centerY, radius, radius)
    --     gfx.drawCircleAtPoint(centerX, centerY, radius)
    -- end

    -- gfx.popContext()  -- Restore the previous graphics context


    gfx.pushContext()  -- Save the current graphics context
    -- gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer4x4)
    -- gfx.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })

    local centerX, centerY = 200, 120  -- Center of the PlayDate screen
    local radii = { 120, 165, 190}  -- Base radii for the circles
    local angleOffset, radiusOffset

    for _, baseRadius in ipairs(radii) do
        local numArcs = 49
        local arcLength = 360 / numArcs / 3
        local arcStep = 360 / numArcs
        for i = 1, numArcs do
            arcStartOffset = 5 * math.sin(math.rad(frameNumber + i * 1)) 
            arcEndOffset = 5 * math.sin(math.rad(frameNumber + i * 1)) 
            radiusOffset = 5 * math.sin(math.rad(frameNumber + i * 1))

            local startAngle = (i - 1) * arcStep + arcStartOffset + baseRadius
            local endAngle = (i - 1) * arcStep + arcLength + arcEndOffset + baseRadius
            local radius = baseRadius + radiusOffset

            gfx.drawArc(centerX, centerY, radius, startAngle, endAngle)
        end
    end

    gfx.popContext()  -- Restore the previous graphics context
end

function updateBeamAngle()
    local crankChange = playdate.getCrankChange()
    beamAngle = (beamAngle + crankChange / 3) % 360
end


function init()
    math.randomseed(playdate.getSecondsSinceEpoch())
    drawLighthouse()
    drawBeam()
    updateWaves()
    initShip(math.random() * 360)
    updateFPS()
end

init()

function playdate.update()
    updateBeamAngle()
    gfx.clear()
    drawLighthouse()
    updateWaves()
    drawBeam()
    updateAndDrawShip()
    gfx.sprite.update()
    frameNumber = frameNumber + 1
    updateFPS()
end
