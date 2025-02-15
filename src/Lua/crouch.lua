
-- crouch
-- id ont know
-- -Pacola

freeslot("SPR2_CROU", "SPR2_CRWA", "S_BOOK_CROUCH", "S_BOOK_CRAWL")

states[S_BOOK_CROUCH] = {
	sprite = SPR_PLAY,
	frame = SPR2_CROU,
	tics = -1,
	nextstate = S_BOOK_CROUCH
}

states[S_BOOK_CRAWL] = {
    sprite = SPR_PLAY,
    frame = SPR2_CRWA|FF_ANIMATE,
    tics = -1,
    nextstate = S_BOOK_CRAWL,
	var1 = E,
	var2 = 2
}

local function canCrouch(p)
	if P_PlayerInPain(p)
	or p.playerstate == PST_DEAD
	or (p.bookgrab and p.bookgrab.active)
	or p.bookgangnam
	or p.powers[pw_carry]
		return false
	end
	return true
end

local function isCrouched(p)
	if p.bookcrouch
	or p.bookslide
		return true
	end
	return false
end

local function initializeVars(p)
	if not (p.mo and p.mo.valid)
	or p.mo.skin ~= "book" return end
	
	p.bookslide = false
	p.bookcrouch = false
	p.spinitem = skins[p.mo.skin].spinitem
end

addHook("PlayerSpawn", initializeVars)

addHook("PlayerThink", function(p)
    if not (p.mo and p.mo.valid)
	or p.mo.skin ~= "book" return end
	
	if p.bookslide == nil
		initializeVars(p)
	end
	
	-- crocuh
	if (p.cmd.buttons & BT_SPIN)
		p.bookspinheld = $+1
	else
		p.bookspinheld = 0
	end
	
	if (p.cmd.buttons & BT_SPIN)
	--if p.bookspinheld == 1
	and canCrouch(p)
	and not isCrouched(p)
	and P_IsObjectOnGround(p.mo)
		if p.speed >= 3*FU
			p.bookslide = true
			S_StartSound(p.mo, sfx_s3k5d)
		else
			p.bookcrouch = true
		end
	end
	
	if p.bookcrouch
		p.pflags = $1|PF_JUMPSTASIS
		if not (p.cmd.buttons & BT_SPIN)
		or not canCrouch(p)
			p.bookcrouch = false
		end
		if FixedDiv(p.speed, p.mo.scale) > p.normalspeed/2
			P_InstaThrust(p.mo, R_PointToAngle2(0, 0, p.mo.momx, p.mo.momy), FixedMul(p.normalspeed/2, p.mo.scale))
		end
		
		if p.panim ~= PA_ETC
			p.bookcpanim = p.panim
		else
			p.panim = p.bookcpanim
		end
		
		if p.speed < FU
			p.mo.state = S_BOOK_CROUCH
		elseif p.mo.state ~= S_BOOK_CRAWL
			p.mo.state = S_BOOK_CRAWL
		end
	elseif p.bookslide
	and not p.bookcrouch
		if p.speed < 3*FU
		or (p.pflags & PF_JUMPED)
		or P_PlayerInPain(p)
		or p.playerstate == PST_DEAD then
			S_StopSoundByID(p.mo, sfx_s3kc8l)
			p.bookslide = false
			p.spinitem = skins[p.mo.skin].spinitem
			p.pflags = $ & ~PF_SPINNING
			if p.mo.state == S_PLAY_ROLL then
				p.mo.state = S_PLAY_FALL
			end
			return
		end
		
		if P_IsObjectOnGround(p.mo) then
			if not S_SoundPlaying(p.mo, sfx_s3kc8l) then
				S_StartSound(p.mo, sfx_s3kc8l)
			end
			P_SpawnSkidDust(p, 8*FU)
		elseif S_SoundPlaying(p.mo, sfx_s3kc8l) then
			S_StopSoundByID(p.mo, sfx_s3kc8l)
		end
		p.spinitem = MT_NULL
		p.pflags = $1|PF_SPINNING
		if p.mo.state ~= S_PLAY_ROLL
			p.mo.state = S_PLAY_ROLL
		end
		P_Thrust(p.mo, R_PointToAngle2(0, 0, p.rmomx, p.rmomy), -p.mo.scale/5)
	elseif p.mo.state >= S_BOOK_CROUCH
	and p.mo.state <= S_BOOK_CRAWL
		p.mo.state = S_PLAY_WALK
	end
end)

addHook("PlayerHeight", function(p)
	if not (p.mo and p.mo.valid)
	or p.mo.skin ~= "book" return end
	
	if p.bookcrouch or p.bookslide return P_GetPlayerSpinHeight(p) end
end)

addHook("PlayerCanEnterSpinGaps", function(p)
	if not (p.mo and p.mo.valid)
	or p.mo.skin ~= "book" return end
	
	if p.bookcrouch or p.bookslide return true end
end)

-- match roll
-- pretty bare-bones, mostly a placeholder maybe??
-- -pac
addHook("PlayerThink", function(p)
	if not (p.mo and p.mo.valid)
	or p.mo.skin ~= "match" then return end
	
	if p.speed > 5*p.mo.scale
	and (p.cmd.buttons & BT_SPIN)
	and P_IsObjectOnGround(p.mo)
	and not (p.pflags & PF_SPINNING) then
		p.pflags = $1|PF_SPINNING
		p.mo.state = S_PLAY_ROLL
		if not p.spectator then
			S_StartSound(p.mo, sfx_spin)
		end
	end
end)