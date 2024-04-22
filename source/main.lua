import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/crank"
import "CoreLibs/timer"

local mathtab = import "mathtab"
local gfx = playdate.graphics

import "globals"
import "dialog"
import "shake"
import "lighthouse"
import "ship"
import "kraken"
import "mermaids"
import "pot"
import "inventory"
import "menu"
import "Wave"

local squareSize = 20
local beamAngle = 0
local beamSpread = 3
local frameNumber = 0

local centerX, centerY = 200, 120
local initialDistance = 140

local shaker = Shake()

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

function didAlert()
    gameState.scoreboard.notified += 1
end

function didCrashShip()
    gameState.scoreboard.wrecked += 1
    spawnShip()
end

function didSaveShip()
    gameState.scoreboard.saved += 1
    spawnShip()
end


function showIntroDialog()
    gameState.isPaused = true
    Dialog("Ah, what a view! One that makes me forget about everything... That reminds me of the days when I was much younger and just started as a lighthouse keeper...", "base", function()
        Dialog("That old thing never rotated by itself and I had to take *the crank* into my own hands... Here, give it a try.", "base", function() 
            gameState.isPaused = false
            lighthouse:equip(0)
            spawnShip()
        end)
    end)
end

function runStory()
    -- First wreck
    if gameState.campaignProgress == 0 and gameState.scoreboard.wrecked >= 1 then
        gameState.scoreboard.wrecked = 0
        gameState.isPaused = true
        Dialog("Uh-oh, no worries. I'll come down later to give the poor guys some coffee and buns. Try to point the beam at the ship for a moment so they see it.", "what", function()
            gameState.isPaused = false
        end)
    end
    -- First ship saved
    if gameState.campaignProgress == 0 and gameState.scoreboard.saved >= 1 then
        gameState.campaignProgress = 1
        gameState.isPaused = true
        Dialog("Nice job! Sometimes the ships arrive in schools, making you rotate it like a ladle in a stockpot!", "base", function()
            gameState.isPaused = false
            spawnShip()
            playdate.timer.performAfterDelay(2000, spawnShip)
        end)
    end
    -- More ships saved, introduce Mermaids
    if gameState.campaignProgress == 1 and gameState.scoreboard.saved >= 6 then
        gameState.campaignProgress = 2
        gameState.isPaused = true
        Dialog("Hmm I wonder what a strange fish it is... it's always nice to see new species in these waters.", "base", function()
            Dialog("I mean...", "what", function()
                Dialog("*M E R M A I D S ! ! !*\n\nThere must be a cannon somewere down there!\n\n*( B )* Switch Equipment", "ah", function() 
                    gameState.isCannonAvailable = true
                    gameState.isPaused = false
                    spawnMermaids()
                end)
            end)
        end)
    end
    -- More ships saved, introduce Kraken
    if gameState.campaignProgress == 2 and gameState.scoreboard.saved >= 12 then
        gameState.campaignProgress = 3
        gameState.isPaused = true
        Dialog("Did you know that octopodes are very smart animals? That wonderful tentacles must belong to a truly magnificent creature...", "base", function()
            Dialog("I mean...", "what", function()
                Dialog("*K R A K E N ! ! !*\n\nCannon cannon cannon!!!", "ah", function() 
                    gameState.isPaused = false
                    spawnKraken()
                end)
            end)
        end)
    end
    -- More ships saved, introducing the Horn
    if gameState.campaignProgress == 3 and gameState.scoreboard.saved >= 20 then
        gameState.campaignProgress = 4
        gameState.campaignCounter = 30 * 60 -- give some time to play
        gameState.isPaused = true
        Dialog("I found a strange horn down in the lighthouse once... but I forgot what it does. I wonder if we could try it today...\n\n*( B )* Switch Equipment", "base", function()
            gameState.isHornAvailable = true
            gameState.isPaused = false
        end)
    end
    -- The sea start boiling...
    if gameState.campaignProgress == 4 and gameState.scoreboard.saved >= 30 then 
        gameState.campaignProgress = 5
        spawnBubbles()
        playdate.timer.performAfterDelay(2000, function()
            -- "I forgot something"
            gameState.campaignProgress = 6
            gameState.isPaused = true
            Dialog("Oh-oh, that looks strange!\nOh wait...\nOh no, not that again!", "base", function()
                Dialog("Every time I do it, I go down the memory lane and forget about it!", "what", function()
                    Dialog("This is not a sea...", "ah", function()
                        Dialog("This is my\n*F I S H S O U P ! ! !*", "base", function()
                            gameState.isPaused = false
                            runFishSoupAnimation()
                        end)
                    end)
                end)
            end)
        end)
    end
end

function runFishSoupAnimation()
    gfx.sprite.removeAll()
    shaker = Shake()
    Pot()
    playdate.timer.performAfterDelay(2000, function()
        Dialog("Well, the soup is ready... see you next time!", "base", function()
            if not gameStore.hasCompletedStory then
                gameStore.hasCompletedStory = true
                playdate.datastore.write(gameStore)
                updateSystemMenu()
            end
            showMenu()
        end)
    end)
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
        if gameState.campaignProgress > 0 then
            Ship(angle - 10)
        end
    end
end

function startStory()
    for _, timer in ipairs(playdate.timer.allTimers()) do
        timer:remove()
    end
    gfx.sprite.removeAll()
    shaker = Shake()
    gameState.isCannonAvailable = false
    gameState.isHornAvailable = false
    gameState.campaignProgress = 0
    gameState.campaignCounter = 0
    gameState.scoreboard.saved = 0
    gameState.scoreboard.wrecked = 0
    gameState.scoreboard.notified = 0
    lighthouse = Lighthouse()
    lighthouse:equip(-1)    -- hide the beam
    Inventory()
    playdate.timer.performAfterDelay(2000, showIntroDialog)
end

function startFreePlay()
    for _, timer in ipairs(playdate.timer.allTimers()) do
        timer:remove()
    end
    gfx.sprite.removeAll()
    shaker = Shake()
    gameState.isCannonAvailable = true
    gameState.isHornAvailable = false
    gameState.campaignProgress = -1
    gameState.scoreboard.saved = 0
    gameState.scoreboard.wrecked = 0
    gameState.scoreboard.notified = 0
    lighthouse = Lighthouse()
    lighthouse:equip(0)
    Inventory()
    spawnShip()
    playdate.timer.performAfterDelay(2000, spawnShip)
    playdate.timer.performAfterDelay(4000, spawnShip)
    playdate.timer.performAfterDelay(15000, freePlayShipGenerator)
end

function spawnMonster()
    local coin = math.random()
    if coin < 0.5 then
        spawnMermaids()
    else
        spawnKraken()
    end
end

function freePlayShipGenerator()
    spawnMonster()
    playdate.timer.performAfterDelay(15000, function()
        spawnMonster()
        playdate.timer.performAfterDelay(5000, freePlayShipGenerator)
    end)
end

function showMenu()
    Menu(function(selection)
        if selection == 0 then
            startStory()
        elseif selection == 1 then
            startFreePlay()
        end
    end)
end

function updateSystemMenu()
    local menu = playdate.getSystemMenu()
    local menuItem, error = menu:addMenuItem("Menu", function()
        gfx.sprite.removeAll()
        shaker = Shake()
        Pot()
        playdate.timer.performAfterDelay(1000, function()
            showMenu()
        end)
    end)
end

function init()
    local s, ms = playdate.getSecondsSinceEpoch()
    math.randomseed(ms,s)
    local store = playdate.datastore.read()
    if store then
        gameStore = store
    end
    if gameStore.hasCompletedStory then
        updateSystemMenu()
        Pot()
        playdate.timer.performAfterDelay(1000, function()
            showMenu()
        end)
    else
        startStory()
    end
end

init()

function playdate.update()
    gfx.sprite.update()
    playdate.timer.updateTimers()
    -- playdate.drawFPS(0, 0)

    if gameState.campaignProgress >= 0 then
        runStory()
    end

    -- gfx.drawText(string.format("SAVED: %d, WRECKED: %d", gameState.scoreboard.saved, gameState.scoreboard.wrecked), 20,5)
end
