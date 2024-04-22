import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/crank"

local mathtab = import "mathtab"
local gfx = playdate.graphics

import "globals"
import "dialog"
import "shake"
import "lighthouse"
import "ship"
import "kraken"
import "mermaids"

local shaker = Shake()

local squareSize = 20
local beamAngle = 0
local beamSpread = 3
local frameNumber = 0

local centerX, centerY = 200, 120
local initialDistance = 140

function shake(amount)
    shaker:setShakeAmount(amount)
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
    Ship(angle)
end

function didCrashShip()
    gameState.scoreboard.failures += 1
end

function didSaveShip()
    gameState.scoreboard.successes += 1
end


function showIntroDialog()
    gameState.isPaused = true
    Dialog("Ah, what a view! One that makes me forget about everything... That reminds me of the days when I was much younger and just started as a lighthouse keeper...", "base", function()
        print("Done 1")
        Dialog("That old thing never rotated by itself and I had to take *the crank* into my own hands... Here, give it a try.", "base", function() 
            print("Done 2")
            gameState.isPaused = false
            spawnShip()
        end)
    end)
end

function runStory()
    -- First wreck
    if gameState.campaignProgress == 0 and gameState.scoreboard.failures >= 1 then
        gameState.scoreboard.failures = 0    -- clean it up in while we are in training mode
        gameState.isPaused = true
        Dialog("Uh-oh, no worries. I'll come down later to give the poor guys some coffee and buns. Try to point the beam at the ship for a moment so they see it.", "base", function()
            gameState.isPaused = false
        end)
    end
    -- First ship saved
    if gameState.campaignProgress == 0 and gameState.scoreboard.successes >= 1 then
        gameState.campaignProgress = 1
        gameState.isPaused = true
        Dialog("Nice job! Sometimes the ships come in hoards, making you rotate it like a spoon in a pot!", "base", function()
            gameState.isPaused = false
        end)
    end
    -- More ships saved, introduce Mermaids
    if gameState.campaignProgress == 1 and gameState.scoreboard.successes >= 6 then
        gameState.campaignProgress = 2
        gameState.isPaused = true
        Dialog("Hmm I wonder what a strange fish it is... it's always nice to see new species in these waters.", "base", function()
            Dialog("I mean...", "base", function()
                Dialog("*M E R M A I D S ! ! !*\nThere must be a cannon somewere *down* there...", "base", function() 
                    gameState.isPaused = false
                    spawnMermaids()
                end)
            end)
        end)
    end
    -- More ships saved, introduce Kraken
    if gameState.campaignProgress == 2 and gameState.scoreboard.successes >= 12 then
        gameState.campaignProgress = 3
        gameState.isPaused = true
        Dialog("Did you know that octopodes are very smart animals? That wonderful tentacles must belong to a truly magnificent creature...", "base", function()
            Dialog("I mean...", "base", function()
                Dialog("*K R A K E N ! ! !*\nCannon cannon cannon!!!", "base", function() 
                    gameState.isPaused = false
                    spawnKraken()
                end)
            end)
        end)
    end
    -- More ships saved, introducing the Horn
    if gameState.campaignProgress == 3 and gameState.scoreboard.successes >= 20 then
        gameState.campaignProgress = 4
        gameState.campaignCounter = 30 * 60 -- give some time to play
        gameState.isPaused = true
        Dialog("I found a strange horn *down* in the lighthouse once... a dangerous thing, calls mermaids! But sometimes can be useful when the traffic becomes that heavy...", "base", function()
            gameState.isPaused = false
        end)
    end
    -- The sea start boiling...
    if gameState.campaignProgress == 4 and gameState.campaignCounter == 0 then 
        gameState.campaignProgress = 5
        gameState.campaignCounter = 30 * 5
        spawnBubbles()
    end
    -- "I forgot something"
    if gameState.campaignProgress == 5 and gameState.campaignCounter == 0 then 
        gameState.campaignProgress = 6
        gameState.isPaused = true
        Dialog("Oh-oh, that looks strange!\nOh wait...\nOh no, not that again!", "base", function()
            Dialog("Every time I do it, I go down the memory lane and forget about it!", "base", function()
                Dialog("This is not a sea...", "base", function()
                    Dialog("This is my\n*F I S H S O U P ! ! !*", "base", function()
                        gameState.isPaused = false
                        runFishSoupAnimation()
                    end)
                end)
            end)
        end)
    end
end

function runFishSoupAnimation()

end

function spawnBubbles()

end

function spawnMermaids()
    if mermaids == nil then 
        mermaids = Mermaids(math.random(0, 360))
    end
end

function spawnKraken() 
    if kraken == nil then
        local angle = math.random(0, 90) - 45
        if math.random(1) > 0.5 then
            angle += 180
        end
        kraken = Kraken(angle)
        Ship(angle + 10)
        Ship(angle - 10)

    end
end

function init()
    local s, ms = playdate.getSecondsSinceEpoch()
    math.randomseed(ms,s)

    lighthouse = Lighthouse()
    -- spawnShip()
    -- spawnShip()
    -- spawnShip()

end

init()

function playdate.update()
    
    gfx.sprite.update()
    if not gameState.isPaused then
        -- updateWaves()
    end
    playdate.drawFPS(0, 0)
    frameNumber = frameNumber + 1 -- helps to move waves now; remove

    if frameNumber == 100 then
        showIntroDialog()
    end

    if gameState.campaignProgress >= 0 then
        runStory()
    end
    if gameState.campaignCounter > 0 then
        gameState.campaignCounter -= 1
    end

    -- gfx.drawText(string.format("SAVED: %d, WRECKED: %d", gameState.scoreboard.successes, gameState.scoreboard.failures), 20,5)
end
