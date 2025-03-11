-- StoneCardSteveAustin
-- By Risky Sweep (@johannhat)
-- See the json for the metadata if you're that bored.

--Hey, it works
sendTraceMessage("WHAT?! Audience is primed.", "StoneCardSteveAustin")

local itWasMeAustin = false
local currentRound = 0

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
			"Stone cards give {C:stone_card_added_chips}+#2#{} chips",
			"(Currently {X:mult,C:white} X#3#{})"
		}
	},
	
	config = { extra = { x_current_mult = 1, x_default_mult = 1, x_mult = 3, stone_card_added_chips = 16, in_ring = false } },

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.x_mult, card.ability.extra.stone_card_added_chips, card.ability.extra.x_current_mult } }
	end,

	-- Sets rarity. 1 common, 2 uncommon, 3 rare, 4 legendary.
	rarity = 1,
	atlas = 'StoneCold',
	pos = { x = 0, y = 0 },
	cost = 4,
	calculate = function(self, card, context)

		-- If the titantron is playing, then activate the ability.
		if (itWasMeAustin and card.ability.extra.in_ring == false) then
			card.ability.extra.in_ring = true
			card.ability.extra.x_current_mult = card.ability.extra.x_mult
		end
		
		-- If the music is done we're done for now.
		if (itWasMeAustin == false and card.ability.extra.in_ring == true) then
			card.ability.extra.in_ring = false
			card.ability.extra.x_current_mult = card.ability.extra.x_default_mult
		end

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
		end

	end
}

--Bugs 
-- 3X does not resume if continue game
-- music does not play if continue from new window
-- Readjust calc?
SMODS.Sound({
    vol = 0.6,
    pitch = 1,
    key = "music_stonecold",
    path = "stonecold-full.ogg",
    select_music_track = function()
	
		local primed = false

		if (G.jokers ~= nil and itWasMeAustin ~= true) then
			for k, v in pairs(G.jokers.cards) do
				if v.config.center.name == "j_stonecardsteveaustin_stonecold" then
					primed = true

					-- --If we are currently in an activated mult (Glass broke in round before save), then let's kick out the jams.
					-- if v.ability.extra.in_ring == true then
					-- 	itWasMeAustin = 1000
					-- end
					break
				end
			end				
		end

		--The start of a new round is the start of a new match. Stone Cold lies in wait.
		if (itWasMeAustin ~= false and G.GAME.round ~= currentRound) or primed == false
		then
			itWasMeAustin = false
		end
		
		--Check the playing cards for a shattered one that has completely dissolved before playing
		--the titantron.
		if primed and G.playing_cards ~= nil then
			for k, v in pairs(G.playing_cards) do
				if (v.shattered == true and v.dissolve == 1) then
					sendTraceMessage("IT WAS ME AUSTIN!!!!", "StoneCardSteveAustin")
					--Save the current round for reference
					currentRound = G.GAME.round
					itWasMeAustin = 1000
					break					
				end
			end	

			-- for k, v in pairs(G.jokers.cards) do
			-- 	if v.config.center.name == "j_stonecardsteveaustin_stonecold" then
			-- 		primed = true

			-- 		--If we are currently in an activated mult (Glass broke in round before resuming game), then let's kick out the jams.
			-- 		if v.ability.extra.in_ring == true then
			-- 			itWasMeAustin = 1000
			-- 		end
			-- 		break
			-- 	end
			-- end	

		end
				
        return itWasMeAustin
    end,
})

--Remove after testing.
SMODS.Keybind{
	key = 'imrich',
	key_pressed = 'm',
    held_keys = {'lctrl'}, -- other key(s) that need to be held

    action = function(self)
        G.GAME.dollars = 1000000
        sendInfoMessage("money set to 1 million", "CustomKeybinds")
    end,
}

SMODS.Back{
    name = "Absolute Deck",
    key = "absolute",
    pos = {x = 0, y = 3},
    config = {polyglass = true},
    loc_txt = {
        name = "Absolute Deck",
        text ={
            "Start with a Deck",
            "full of {C:attention,T:e_polychrome}Poly{}{C:red,T:m_glass}glass{} cards"
        },
    },
    apply = function()


        G.E_MANAGER:add_event(Event({
            func = function()
                for i = #G.playing_cards, 1, -1 do
                    G.playing_cards[i]:set_ability(G.P_CENTERS.m_glass)
                    G.playing_cards[i]:set_edition({
                        polychrome = true
                    }, true, true)
                end
                return true
            end
        }))
    end
}