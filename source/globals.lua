screen = { width = 400, height = 240, centerX = 200, centerY = 120, radius = 240 }

lighthouse = nil
mermaids = nil
kraken = nil

scoreboard = { successes = 0, failures = 0 }

gameState = {
    isPaused = false,
    scoreboard = scoreboard,
    campaignProgress = 0,       -- -1 is free play, >=0 is the story mode
    campaignCounter = 0
}
