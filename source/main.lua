import "CoreLibs/graphics"
import "CoreLibs/crank"
import "ship"


local mathtab = import "mathtab"
local gfx = playdate.graphics
local ships = {}
local scoreboard = { successes = 0, failures = 0 }

local squareSize = 20
local beamAngle = 0
local beamSpread = 3
local frameNumber = 0
local frameCount = 0
local startTime = playdate.getCurrentTimeMilliseconds()
local lastFPS = 0  -- Store the last calculated FPS

local centerX, centerY = 200, 120
local initialDistance = 140

function updateAndDrawShip()
    for i = #ships, 1, -1 do
        local ship = ships[i]

        local diff = ship.angle - beamAngle
        if ship.deviationAngle == 0 and math.abs(diff) <= beamSpread * 2 then
            if ship.noticeTimer >= 15 and ship.deviationAngle == 0 then
                ship.deviationAngle = diff > 0 and 30 or -30
                spawnShip()
            elseif ship.hasAppeared then
                ship.noticeTimer = ship.noticeTimer + 1
            end
        end

        ship:update()
        ship:draw()

        if ship:isInCenter() then
            table.remove(ships, i)
            scoreboard.failures = scoreboard.failures + 1
            spawnShip()
        elseif ship:isOutsideScreen() then
            table.remove(ships, i)
            scoreboard.successes = scoreboard.successes + 1
        end
    end
end

function drawLighthouse()
    gfx.pushContext()
    gfx.setDrawOffset(200, 120)
    gfx.drawRect(-squareSize/2, -squareSize/2, squareSize, squareSize)
    gfx.popContext()
end

function drawBeam()
    -- local x1 = 200 + 240 * math.cos(math.rad(beamAngle - beamSpread)) 
    -- local y1 = 120 + 240 * math.sin(math.rad(beamAngle - beamSpread))
    -- local x2 = 200 + 240 * math.cos(math.rad(beamAngle + beamSpread)) 
    -- local y2 = 120 + 240 * math.sin(math.rad(beamAngle + beamSpread))

    local x1 = 200 + 240 * mathtab.cos(beamAngle - beamSpread)
    local y1 = 120 + 240 * mathtab.sin(beamAngle - beamSpread)
    local x2 = 200 + 240 * mathtab.cos(beamAngle + beamSpread) 
    local y2 = 120 + 240 * mathtab.sin(beamAngle + beamSpread)

    -- gfx.setColor(gfx.kColorWhite)
    -- gfx.setColor(gfx.kColorBlack)
    -- gfx.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
    gfx.setPattern({ ~0x04, ~0x40, ~0x00, ~0x08, ~0x00, ~0x01, ~0x20, ~0x00 })
    gfx.fillTriangle(centerX, centerY, x1, y1, x2, y2)
    gfx.drawLine(200, 120, x1, y1)
    gfx.drawLine(200, 120, x2, y2)
    gfx.setColor(gfx.kColorBlack)
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
    gfx.drawText(string.format("FPS: %d SAFE: %d WRECKED: %d", lastFPS, scoreboard.successes, scoreboard.failures), 10, 10)
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


    -- gfx.pushContext()  -- Save the current graphics context
    -- gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer4x4)
    -- gfx.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })

    local centerX, centerY = 200, 120  -- Center of the PlayDate screen
    local radii = { 120, 165, 190}  -- Base radii for the circles
    local angleOffset, radiusOffset

    for _, baseRadius in ipairs(radii) do
        local numArcs = (baseRadius / 4) // 1
        local arcLength = 360 / numArcs / 3
        local arcStep = 360 / numArcs
        for i = 1, numArcs do

            local arcStartOffset = 5 * mathtab.sin(frameNumber + i * 1 + baseRadius)
            local arcEndOffset   = 5 * mathtab.sin(frameNumber + i * 1 + baseRadius)
            local radiusOffset   = 5 * mathtab.sin(frameNumber + i * 1)

            local startAngle = (i - 1) * arcStep + arcStartOffset -- + baseRadius
            local endAngle   = (i - 1) * arcStep + arcLength + arcEndOffset -- + baseRadius
            local radius = baseRadius + radiusOffset

            local startY = centerY + baseRadius * mathtab.sin(startAngle-90)
            local endY = centerY + baseRadius * mathtab.sin(endAngle-90)

            if baseRadius > 180 then
                gfx.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
            else
                gfx.setColor(gfx.kColorBlack)
            end

            if startY > 0 and startY < 240 and endY > 0 and endY < 240 then
                gfx.drawArc(centerX, centerY, radius, startAngle, endAngle)
            end
        end
    end
    gfx.setColor(gfx.kColorBlack)
    -- gfx.popContext()  -- Restore the previous graphics context
end

function updateBeamAngle()
    local crankChange = playdate.getCrankChange()
    beamAngle = (beamAngle + crankChange / 4) % 360
end

function spawnShip()
    local angle = math.random(0, 360)
    table.insert(ships, Ship:new(angle))
end

function init()
    math.randomseed(playdate.getSecondsSinceEpoch())
    drawLighthouse()
    drawBeam()
    updateWaves()
    spawnShip()
    spawnShip()
    spawnShip()
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
