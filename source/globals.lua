screen = { width = 400, height = 240, centerX = 200, centerY = 120, radius = 240 }

lighthouse = nil
mermaids = nil
kraken = nil

scoreboard = { saved = 0, wrecked = 0, notified = 0 }

gameState = {
    isPaused = false,
    scoreboard = scoreboard,
    campaignProgress = 0,       -- -1 is free play, >=0 is the story mode
    campaignCounter = 0,

   	isCannonAvailable = false,
   	isHornAvailable = false
}

gameStore = {
	hasCompletedStory = false
}