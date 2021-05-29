bf_orig_y = 0
bf_orig_x = 0
gf_orig_y = 0
gf_orig_x = 0

function start (song)
	bf_orig_y = getActorY("boyfriend")
	bf_orig_x = getActorX("boyfriend")
	gf_orig_y = getActorY("girlfriend")
	gf_orig_x = getActorX("girlfriend")
	print("Song: " .. song .. " @ " .. bpm .. " donwscroll: " .. downscroll)
end


function update (elapsed) -- example https://twitter.com/KadeDeveloper/status/1382178179184422918
	-- local currentBeat = (songPos / 1000)*(bpm/60)
	-- 	for i=0,7 do
	-- 		setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin((currentBeat + i*0.25) * math.pi), i)
	-- 		setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*0.25) * math.pi), i)
	-- 	end
    -- if curStep >= 672 and curStep < 820 then
				local currentBeat = (songPos / 1000)*(bpm/60)
		--for i=0,7 do
			-- setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin((currentBeat + i*0.25) * math.pi), i)
			-- setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*0.25) * math.pi), i)
            --end
        -- setActorX(_G['defaultStrum5X'], 6)
        -- setActorY(_G['defaultStrum5Y'], 6)
				-- setActorX(_G['defaultStrum6X'], 5)
        -- setActorY(_G['defaultStrum6Y'], 5)

				for i=0,7 do
					setActorAngle(currentBeat, i)
					setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin((currentBeat + i*0.25) * math.pi), i)
					setActorY(_G['defaultStrum'..i..'Y'] + 2* 32 * math.cos((currentBeat + i*0.25) * math.pi), i)
				end

				-- camHudAngle = camHudAngle + currentBeat/100;
				-- setCamPosition(32 * math.sin((currentBeat) * math.pi), 32 * math.cos((currentBeat) * math.pi))
				-- setHudPosition(32 * math.cos((currentBeat) * math.pi), 32 * math.sin((currentBeat) * math.pi))
				-- setActorAngle(currentBeat, "dad")
				setActorScale(math.abs((currentBeat*0.5)%2 - 1), "dad")
				setActorX(bf_orig_x + 32 * math.sin(currentBeat*5) * math.pi, "boyfriend")
				setActorY(bf_orig_y + 32 * math.cos(currentBeat*5) * math.pi, "boyfriend")

				--if currentBeat % 2 >= 1 then
				--	setActorX(bf_orig_x*(currentBeat%2), "girlfriend")
				--	setActorY(bf_orig_y*(currentBeat%2), "girlfriend")
				--else
				--	setActorX(gf_orig_x*(currentBeat%2), "girlfriend")
				--	setActorY(gf_orig_y*(currentBeat%2), "girlfriend")
				--end

	-- else
        -- setActorX(_G['defaultStrum5X'], 5)
				-- setActorY(_G['defaultStrum5Y'], 5)
				-- setActorX(_G['defaultStrum6X'], 6)
        -- setActorY(_G['defaultStrum6Y'], 6)
        -- for i=0,7 do
        --     setActorX(_G['defaultStrum'..i..'X'],i)
        --     setActorX(_G['defaultStrum'..i..'Y'],i)
        -- end
    -- end

		--if getRenderedNotes() ~= 0 then
		--	closest_note_x = getRenderedNoteX(0)
		--	closest_note_y = getRenderedNoteY(0)
		--	if closest_note_x > hudWidth/2 then  -- BF
		--		-- setRenderedNotePos(closest_note_x + 32 * math.sin((currentBeat + i*0.25) * math.pi), closest_note_y, 0)
		--		setRenderedNotePos(closest_note_x + 32, 0, 0)
		--	end
		--end

		-- diff = _G['defaultStrum4X'] - _G['defaultStrum0X']

		rendered_notes = getRenderedNotes()

		--[[if rendered_notes ~= 0 then
			for i=0, rendered_notes-1 do
				closest_note_x = getRenderedNoteX(i)
				closest_note_y = getRenderedNoteY(i)
				if closest_note_y > hudHeight/3 then
					-- setRenderedNotePos(closest_note_x + 32 * math.sin((currentBeat + i*0.25) * math.pi), closest_note_y, 0)
					-- setRenderedNotePos(closest_note_x, hudHeight/3 + (hudHeight-closest_note_y), i)
					-- setRenderedNotePos(closest_note_x, hudHeight/3 + (closest_note_y-hudHeight/3)/1.5, i)
					if closest_note_x > hudWidth/2 then  -- BF
						setRenderedNotePos(closest_note_x - diff, closest_note_y, i)
					else
						setRenderedNotePos(closest_note_x + diff, closest_note_y, i)
					end
				end
			end

		end]]

		--[[if rendered_notes ~= 0 then
			for i=0, rendered_notes-1 do
				note_x = getRenderedNoteX(i)
				note_y = getRenderedNoteY(i)
				setRenderedNoteAlpha(((screenHeight-note_y)/screenHeight), i)
				-- setRenderedNoteScale(2*((screenHeight-note_y)/screenHeight)-1, i)
				-- setRenderedNotePos(note_x, note_y, i)
			end
		end]]


end

function beatHit (beat)
   -- do nothing
end

function stepHit (step)
	-- do nothing
end

print("Mod Chart script loaded :)")
