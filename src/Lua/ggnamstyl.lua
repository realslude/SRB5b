
-- opacandastar
-- -Pacola

freeslot("SPR2_GANG", "S_BOOK_GANGNAM")

states[S_BOOK_GANGNAM] = {
	sprite = SPR_PLAY,
	frame = SPR2_GANG,
	tics = -1,
	nextstate = S_BOOK_GANGNAM,
	var1 = N,
	var2 = 2
}

local function canGangnam(p)
	if P_PlayerInPain(p)
	or p.playerstate == PST_DEAD
	or (p.bookgrab and p.bookgrab.active)
	or p.bookcrouch
	or p.bookslide
	or p.powers[pw_carry]
		return false
	end
	return true
end

local gangnamPos = 0

addHook("NetVars", function(net)
	gangnamPos = net($)
end)

local function isMarioMode()
	return mapheaderinfo[gamemap] and (mapheaderinfo[gamemap].typeoflevel & TOL_MARIO) and true or false
end

addHook("PlayerThink", function(p)
	if not (p.mo and p.mo.valid)
	or not SRB5b_skinCheck(p.mo.skin) then
		if p.bookgangnam then
			if p.mo.state == S_BOOK_GANGNAM then
				p.mo.state = S_PLAY_STND
			end
			if p.bookgangnamsong then
				P_RestoreMusic(p)
				p.bookgangnamsong = false
			end
			p.bookgangnam = false
		end
		return
	end
	
	if (p.cmd.buttons & BT_CUSTOM3)
		p.bookc3held = $+1
	else
		p.bookc3held = 0
	end
	
	if p.bookc3held == 1
	and p.bookgangnam
	or not canGangnam(p)
		p.bookgangnam = false
	elseif p.bookc3held == 1
	and (p.panim == PA_IDLE or p.panim == PA_EDGE)
	and canGangnam(p)
		p.bookgangnam = true
	end
	
	if p.bookgangnam
		local musPlaying = S_MusicPlaying(p)
		local musName = S_MusicName(p)
		local musLen = S_GetMusicLength()
		
		local jingleName = isMarioMode() and "BOKMAR" or "BOKGNG"
		if tostring(musName) then musName = tostring($):upper() end
		
		if not p.bookgangnamsong then
			p.bookgangnamsong = true
			P_PlayJingleMusic(p, jingleName, 0, true)
			musLen = S_GetMusicLength()
		end
		
		if musPlaying
		and musLen > 0 then
			local didLoop = false
			local uPos = gangnamPos
			while uPos > musLen do
				uPos = $-musLen
				didLoop = true
			end
			if didLoop then uPos = $+(S_GetMusicLoopPoint(p) or 0) end
			
			if musName ~= jingleName then
				S_ChangeMusic(jingleName, true, p, 0, (uPos or 0))
			elseif musName == jingleName then
				S_SetMusicPosition(uPos)
			end
		end
		
		if p.mo.state ~= S_BOOK_GANGNAM
			p.mo.state = S_BOOK_GANGNAM
		else
			local state = states[p.mo.state]
			-- srb2 wants to screw up our anim?
			-- how about we just do it ourselves then!!
			-- -pac
			p.mo.frame = (leveltime / state.var2) % (state.var1 + 1)
		end
		p.pflags = $1|PF_FULLSTASIS
	else
		if p.mo.state == S_BOOK_GANGNAM
			p.mo.state = S_PLAY_STND
		end
		if p.bookgangnamsong then
			P_RestoreMusic(p)
			p.bookgangnamsong = false
		end
	end
end)

addHook("ThinkFrame", function()
	local isGangnam = false
	for p in players.iterate do
		if p.bookgangnam then
			isGangnam = true
			break
		end
	end
	
	if isGangnam then
		gangnamPos = $+(MUSICRATE/TICRATE)
	elseif gangnamPos then
		gangnamPos = 0
	end
end)