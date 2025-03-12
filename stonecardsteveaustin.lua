-- StoneCardSteveAustin
-- By Risky Sweep (@johannhat)
-- See the json for the metadata if you're that bored.

--Hey, it works
sendTraceMessage("WHAT?! Audience is primed.", "StoneCardSteveAustin")

local isCardActive = false
local itWasMeAustin = false

--Creates an atlas for cards to use
SMODS.Atlas {
	-- Key for code to find it with
	key = "StoneCold",
	-- The name of the file, for the code to pull the atlas from
	path = "stonecold.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}

SMODS.Joker {
	key = 'stonecold',
	loc_txt = {
		name = 'Stone Cold Joker',
		text = {
			"If a glass card is broken gain",
			"{X:mult,C:white} X#1#{} Mult until the next round.",
			"Stone cards give {C:chips}+#2#{} chips",
			"(Currently {X:mult,C:white} X#3#{})"
		}
	},
	
	config = { extra = { x_current_mult = 1, x_default_mult = 1, x_mult = 3, stone_card_added_chips = 16, in_ring = false, current_round = 0 } },

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.x_mult, card.ability.extra.stone_card_added_chips, card.ability.extra.x_current_mult } }
	end,

	-- Sets rarity. 1 common, 2 uncommon, 3 rare, 4 legendary.
	rarity = 2,
	atlas = 'StoneCold',
	pos = { x = 0, y = 0 },
	cost = 4,
	calculate = function(self, card, context)

		sendTraceMessage("XMult: " .. card.ability.extra.x_current_mult , "StoneCardSteveAustin")		

		if context.joker_main then			
			if (card.ability.extra.in_ring) then
				sendTraceMessage("Getting the X Mult!!!", "StoneCardSteveAustin")			

				return {
					Xmult_mod = card.ability.extra.x_current_mult,
					message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.x_current_mult } }
				}
			else
				sendTraceMessage("Nada", "StoneCardSteveAustin")			
				return {}
			end

		end

		if context.individual and context.cardarea == G.play then
			if context.other_card.ability.effect == 'Stone Card' then
				
				return {
					message = "WHAT?!",
					chips = card.ability.extra.stone_card_added_chips,
					card = context.other_card
				}
			end
		end

		if context.end_of_round and context.cardarea == G.jokers then		
			card.ability.extra.in_ring = false
			card.ability.extra.x_current_mult = card.ability.extra.x_default_mult
			card.ability.extra.current_round = 0
		end

	end
}

SMODS.Sound({
    vol = 0.6,
    pitch = 1,
    key = "music_stonecold",
    path = "stonecold-full.ogg",
    select_music_track = function()
	
		local primed = false
		local lastActiveCardRound = 0

		if (G.jokers ~= nil and itWasMeAustin ~= true) then
			for k, v in pairs(G.jokers.cards) do
				if v.config.center.name == "j_stonecardsteveaustin_stonecold" then
					primed = true
					isCardActive = v.ability.extra.in_ring 
					lastActiveCardRound = v.ability.extra.current_round
					break
				end
			end				
		end

		--The start of a new round is the start of a new match. Stone Cold lies in wait.
		if (itWasMeAustin ~= false and G.GAME.round ~= lastActiveCardRound) or primed == false then

			itWasMeAustin = false

			--Set the default mult from here.
			if (G.jokers ~= nil) then
				for k, v in pairs(G.jokers.cards) do
					if v.config.center.name == "j_stonecardsteveaustin_stonecold" then
						v.ability.extra.in_ring = false
						v.ability.extra.x_current_mult = v.ability.extra.x_default_mult
						break
					end
				end		
			end

		elseif primed and isCardActive == true then
			itWasMeAustin = 1000
		elseif primed and G.playing_cards ~= nil then

			--Check for broken class in the playing cards.
			for k, v in pairs(G.playing_cards) do
				if (v.shattered == true and v.dissolve == 1) then
					sendTraceMessage("IT WAS ME AUSTIN!!!!", "StoneCardSteveAustin")

					--Set the mult from here.
					if (G.jokers ~= nil) then
						for k, v in pairs(G.jokers.cards) do
							if v.config.center.name == "j_stonecardsteveaustin_stonecold" then
								v.ability.extra.in_ring = true
								v.ability.extra.x_current_mult = v.ability.extra.x_mult
								v.ability.extra.current_round = G.GAME.round
								break
							end
						end		
					end

					--Save the current round for reference
					itWasMeAustin = 1000

					break					
				end
			end	
		end
		
				
        return itWasMeAustin
    end,
})
