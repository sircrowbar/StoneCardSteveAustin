-- StoneCardSteveAustin
-- By Risky Sweep (@johannhat)
-- See the json for the metadata if you're that bored.

--Hey, it works
sendTraceMessage("WHAT?", "StoneCardSteveAustin")

local itWasMeAustin = false
local currentRound = 0

SMODS.Sound({
    vol = 0.6,
    pitch = 1,
    key = "music_stonecold",
    path = "stonecold-full.ogg",
    select_music_track = function()
	
		--The start of a new round is the start of a new match. Stone Cold lies in wait.
		if itWasMeAustin ~= false and G.GAME.round > currentRound then
			sendTraceMessage("I'll take it from here, Nurse", "StoneCardSteveAustin")			
			itWasMeAustin = false
		end
		
		--Check the playing cards for a shattered one that has completely dissolved before playing
		--the titantron.
		if G.playing_cards ~= nil then
			for k, v in pairs(G.playing_cards) do
				if (v.shattered == true and v.dissolve == 1) then
					sendTraceMessage("IT WAS ME AUSTIN!!!!", "StoneCardSteveAustin")
					--Save the current round for reference
					currentRound = G.GAME.round
					itWasMeAustin = 1000
				end
			end
		end
				
        return itWasMeAustin
    end,
})