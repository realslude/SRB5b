
-- gives book a grab
-- similar to bfdia 5b i think

-- future pac here
-- this is kind of janky
-- even after "rewrite"

-- future future pac here
-- now i've made a true rewrite

-- sludesus here
-- "I'm also in the grab_stuff_the_lua.lua too!"

local deadlythrow = CV_RegisterVar({
	name = "book_deadlythrow",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
})

local grabbrain = CV_RegisterVar({
	name = "book_grabbrain",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
})

local throwaccel = CV_RegisterVar({
	name = "book_throwaccel",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
})

local keepinv = CV_RegisterVar({
	name = "book_keepinventory",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
})

local grabweight = CV_RegisterVar({
	name = "book_grabweight",
	defaultvalue = "On",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
})

local grabanything = CV_RegisterVar({
	name = "book_grabanything",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
})

local grabgrief = CV_RegisterVar({
	name = "book_grabgrief",
	defaultvalue = "On",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
})

freeslot("SPR2_HOLD", "S_BOOK_HOLD", "SPR2_HOWA", "S_BOOK_HOLDWALK", "SPR2_HOFA", "S_BOOK_HOLDJUMP", "SPR2_HODO", "S_BOOK_HOLDFALL")

spr2defaults[SPR2_HOWA] = SPR2_WALK
spr2defaults[SPR2_HOFA] = SPR2_JUMP
spr2defaults[SPR2_HODO] = SPR2_HOFA

states[S_BOOK_HOLD] = {
	sprite = SPR_PLAY,
	frame = SPR2_HOLD,
	tics = -1,
	nextstate = S_BOOK_HOLD
}

states[S_BOOK_HOLDWALK] = {
	sprite = SPR_PLAY,
	frame = SPR2_HOWA|FF_ANIMATE,
	tics = -1,
	nextstate = S_BOOK_HOLDWALK,
	var1 = 64,
	var2 = 2
}

states[S_BOOK_HOLDJUMP] = {
	sprite = SPR_PLAY,
	frame = SPR2_HOFA,
	tics = -1,
	nextstate = S_BOOK_HOLDJUMP
}

states[S_BOOK_HOLDFALL] = {
	sprite = SPR_PLAY,
	frame = SPR2_HODO,
	tics = -1,
	nextstate = S_BOOK_HOLDFALL
}

freeslot("MT_BOOK_THROWNHITBOX")

mobjinfo[MT_BOOK_THROWNHITBOX] = {
	doomednum = -1,
	spawnstate = S_INVISIBLE,
	flags = MF_SCENERY
}

local function canGrab(p)
	if P_PlayerInPain(p)
	or p.playerstate == PST_DEAD
	--or (p.bookheldplyr and p.bookheldplyr.valid)
	or (p.mo.bookheldplyr and p.mo.bookheldplyr.valid)
	or (p.pflags & PF_STASIS)
		return false
	end
	return true
end

local function shouldHurt(pmo, pmo2)
	local p = pmo.player
	local p2 = pmo2.player
	
	--if (G_CoopGametype() and ff == 1)
	return (G_RingSlingerGametype() and not G_TagGametype() and not G_GametypeHasTeams())
	or G_CompetitionGametype()
	or (G_GametypeHasTeams() and p2.ctfteam ~= p.ctfteam)
	or (G_TagGametype() and (p.pflags & PF_TAGIT) and not (p2.pflags & PF_TAGIT))
	or CV_FindVar("friendlyfire").value == 1
	/*	return true
	end

	return false*/
end

local function skinCarry(s)
	return (
		s == "book"
		or s == "match"
	)
end

local function initVar(p)
	return {
		active = false,
		mobj = nil,
		keepInv = {
			type = nil,
			pnum = -1,
			state = S_INVISIBLE,
			frame = A,
			health = 0
		}
	}
end

local function grabMo(p, mo, store)
	if store == nil then store = true end
	local g = p.bookgrab
	g.active = true
	mo.bookheldplyr = p.mo
	if not mo.bookoldflags then
		mo.bookoldflags = mo.flags
	end
	mo.oldviewmobjthing = mo.dontdrawforviewmobj
	local brain = grabbrain.value and MF_SCENERY or MF_NOTHINK
	local flags = brain|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOCLIPTHING|MF_NOGRAVITY
	if (mo.player and mo.player.valid) then
		flags = $ & ~brain
	end
	mo.flags = $1|flags
	mo.dontdrawforviewmobj = p.mo
	g.mobj = mo
	
	if not store then return end
	
	local inv = p.bookgrab.keepInv
	inv.type = mo.type
	inv.pnum = (mo.player and mo.player.valid) and #mo.player or -1
end

addHook("PlayerSpawn", function(p)
	if not (p.mo and p.mo.valid)
	or not skinCarry(p.mo.skin) then
		p.bookgrab = nil
		return
	end
	
	if p.bookgrab
	and p.bookgrab.keepInv.type
	and keepinv.value then
		local g = p.bookgrab
		g.active = true
		local inv = p.bookgrab.keepInv
		if inv.type ~= MT_PLAYER then
			local mo = P_SpawnMobj(p.mo.x, p.mo.y, p.mo.z, inv.type)
			mo.state = inv.state
			mo.frame = inv.frame
			mo.health = inv.health
			grabMo(p, mo, false)
		elseif (players[inv.pnum] and players[inv.pnum].valid)
		and (players[inv.pnum].mo and players[inv.pnum].mo.valid) then
			grabMo(p, players[inv.pnum].mo)
		end
		inv.type = nil
		inv.pnum = -1
	else
		p.bookgrab = initVar(p)
	end
end)

local stateList = {
	[PA_IDLE] = S_PLAY_STND,
	[PA_EDGE] = S_PLAY_EDGE,
	[PA_WALK] = S_PLAY_WALK,
	[PA_RUN] = S_PLAY_RUN,
	[PA_JUMP] = S_PLAY_JUMP,
	[PA_SPRING] = S_PLAY_SPRING,
	[PA_FALL] = S_PLAY_FALL
}

local function grabbedWallStuff(p, mo)
	if stateList[p.panim]
	and p.mo.state ~= stateList[p.panim] then
		p.mo.state = stateList[p.panim]
	end
	
	P_SetOrigin(mo, p.mo.x, p.mo.y, p.mo.z+p.mo.height/2)
	local floorZ = P_FloorzAtPos(mo.x, mo.y, mo.z, mo.height)
	local ceilZ = P_CeilingzAtPos(mo.x, mo.y, mo.z, mo.height)
	local limit = 0
	while mo.z < mo.floorz
	or mo.z+mo.height > mo.ceilingz do
		P_SetOrigin(mo, p.mo.x-P_ReturnThrustX(mo, p.drawangle, mo.radius*2), p.mo.y-P_ReturnThrustY(mo, p.drawangle, mo.radius*2), p.mo.z+p.mo.height/2)
		floorZ = P_FloorzAtPos(mo.x, mo.y, mo.z, mo.height)
		ceilZ = P_CeilingzAtPos(mo.x, mo.y, mo.z, mo.height)
		
		limit = $+1
		if limit > 9999 then break end
		--if not P_PointInSubsector
	end
	
	if limit > 9999 then
		P_SetOrigin(mo, p.mo.x, p.mo.y, p.mo.z+p.mo.height/2)
	end
	
	mo.flags = $ & ~(MF_NOCLIP|MF_NOCLIPHEIGHT)
	local dist = p.mo.radius+mo.radius+FU
	--P_SetOrigin(mo, p.mo.x-P_ReturnThrustX(mo, p.drawangle, dist), p.mo.y-P_ReturnThrustY(mo, p.drawangle, dist), p.mo.z+p.mo.height/2)
	P_TryMove(mo, mo.x+P_ReturnThrustX(mo, p.drawangle, dist), mo.y+P_ReturnThrustY(mo, p.drawangle, dist), true)
	mo.momx = p.mo.momx
	mo.momy = p.mo.momy
	
	if not (mo.player and mo.player.valid) then -- please don't do thsi for players D:
		local hitbox = P_SpawnMobj(mo.x, mo.y, mo.z, MT_BOOK_THROWNHITBOX)
		hitbox.target = mo
		hitbox.tracer = p.mo
	end
end

local function releaseMo(p)
	if not p.bookgrab then return end
	local g = p.bookgrab
	local mo = g.mobj
	
	grabbedWallStuff(p, mo)
	P_TryMove(mo, mo.x+P_ReturnThrustX(mo, p.drawangle, p.mo.scale+mo.scale), mo.y+P_ReturnThrustY(mo, p.drawangle, p.mo.scale+mo.scale), true)
	
	P_Thrust(mo, p.drawangle, 3*FU)
	P_SetObjectMomZ(mo, 3*FU)
	P_XYMovement(mo)
	P_ZMovement(mo)
	
	mo.flags = mo.bookoldflags
	mo.bookoldflags = nil
	mo.dontdrawforviewmobj = mo.oldviewmobjthing
	mo.bookheldplyr = nil
	if (mo.player and mo.player.valid) then
		P_MovePlayer(mo.player)
	end
	g.active = false
	g.mobj = nil
end

local function throwMo(p)
	if not p.bookgrab then return end
	local g = p.bookgrab
	local mo = g.mobj
	
	if not (mo and mo.valid) then return end
	
	if mo.type == MT_SIGN
	and (mo.target and mo.target.valid) then
		mo.target = p.mo
		mo.state = S_SIGNSPIN1
		if mo.info.seesound then
			S_StartSound(mo, mo.info.seesound)
		end
	end
	
	grabbedWallStuff(p, mo)
	
	if (mo.player and mo.player.valid)
	and not shouldHurt(p.mo, mo) then
		mo.state = S_PLAY_ROLL
		mo.player.pflags = ($1|PF_SPINNING) & ~(PF_STARTJUMP|PF_JUMPED|PF_THOKKED)
	end
	
	if throwaccel.value
	or FixedHypot(mo.momx, mo.momy) < 10*FU then
		P_Thrust(mo, p.drawangle, 10*FU)
	end
	P_SetObjectMomZ(mo, 7*FU)
	P_XYMovement(mo)
	P_ZMovement(mo)
	mo.flags = mo.bookoldflags
	mo.bookoldflags = nil
	mo.dontdrawforviewmobj = mo.oldviewmobjthing
	mo.bookheldplyr = nil
	if (mo.player and mo.player.valid) then
		P_MovePlayer(mo.player)
	end
	g.active = false
	g.mobj = nil
end

addHook("ThinkFrame", function()
	for p in players.iterate do
		if not (p.mo and p.mo.valid)
		or not skinCarry(p.mo.skin) then
			if p.bookgrab then
				if p.bookgrab.active then
					releaseMo(p)
				end
				p.bookgrab = nil
			end
			continue
		end
		
		if p.bookgrab == nil
		or p.playerstate == PST_DEAD then
			if p.bookgrab
			and p.bookgrab.active then
				releaseMo(p)
			end
			p.bookgrab = initVar(p)
		end
		local g = p.bookgrab
		
		if not g.active then
			if g.keepInv
			and g.keepInv.type ~= nil then
				local inv = g.keepInv
				inv.type = nil
				inv.state = S_INVISIBLE
				inv.frame = A
				inv.health = 0
			end
			if (p.cmd.buttons & BT_CUSTOM1)
			and not (p.lastbuttons & BT_CUSTOM1)
			and canGrab(p) then
				local closestMo
				local closestDist = INT32_MAX
				searchBlockmap("objects", function(_, mo)
					local moDist = R_PointToDist2(p.mo.x, p.mo.y, mo.x, mo.y)
					if not ((mo.flags & (MF_ENEMY|MF_PUSHABLE|MF_SPRING|MF_MONITOR)) or mo.info.bookgrabbable or grabanything.value)
					and not ((mo.player and mo.player.valid) and grabgrief.value)
					or moDist > p.mo.radius+mo.radius+64*p.mo.scale
					or moDist >= closestDist
					or (mo.bookheldplyr and mo.bookheldplyr.valid)
					or R_PointToDist2(0, p.mo.z, 0, mo.z) > p.mo.height+mo.height+16*p.mo.scale then return end
					
					closestMo = mo
					closestDist = moDist
				end, p.mo, p.mo.x-64*p.mo.scale, p.mo.x+64*p.mo.scale, p.mo.y-64*p.mo.scale, p.mo.y+64*p.mo.scale)
				
				if closestMo then
					grabMo(p, closestMo)
					return
				end
			end
		else
			if not (g.mobj and g.mobj.valid)
			or not canGrab(p) then
				if (g.mobj and g.mobj.valid) then
					releaseMo(p)
				end
				g.active = false
				g.mobj = nil
				return
			end
			local mo = g.mobj
			local p2 = (mo.player and mo.player.valid) and mo.player or nil
			local dist = p.mo.radius+mo.radius
			if p2 then
				p2.pflags = $1|PF_FULLSTASIS
				p2.drawangle = p.drawangle
				if mo.state ~= S_PLAY_STUN then
					mo.state = S_PLAY_STUN
				end
				
				if (p2.cmd.buttons & BT_JUMP)
				and not (p2.lastbuttons & BT_JUMP)
				and not shouldHurt(p.mo, mo) then
					releaseMo(p)
					mo.momx = p.mo.momx
					mo.momy = p.mo.momy
					P_MovePlayer(p2)
					p2.pflags = $|PF_JUMPDOWN & ~(PF_STARTJUMP|PF_JUMPED|PF_JUMPSTASIS)
					P_DoJump(p2)
					return
				end
			else
				mo.angle = p.drawangle
			end
			g.keepInv.state = mo.state
			g.keepInv.frame = mo.frame
			g.keepInv.health = mo.health
			mo.momx = p.mo.momx
			mo.momy = p.mo.momy
			mo.momz = p.mo.momz
			P_MoveOrigin(mo, p.mo.x+P_ReturnThrustX(p.mo, p.drawangle, dist), p.mo.y+P_ReturnThrustY(p.mo, p.drawangle, dist), p.mo.z+p.mo.height/2)
			
			if not P_IsObjectOnGround(p.mo) -- copying code HOORAY!!
			and not (p.mo.eflags & MFE_GOOWATER)
			and grabweight.value
			and not p.powers[pw_super] then
				local baseGrav = FU/2 -- base gravity is 0.5
				local curGrav = abs(P_GetMobjGravity(p.mo)) -- get current gravity
				local gravMul = FixedDiv(curGrav, baseGrav) -- get the factor we should multiply the weight so it should work similarly on all gravities, i think thats how Physics work
				local moWeight = -abs(FixedDiv(FixedDiv(mo.radius+mo.height, 112*FU), FU+FU/2))
				P_SetObjectMomZ(p.mo, FixedMul(moWeight, gravMul), true)
			end
			
			if (p.cmd.buttons & BT_CUSTOM1)
			and not (p.lastbuttons & BT_CUSTOM1) then
				throwMo(p)
			elseif (p.cmd.buttons & BT_CUSTOM2)
			and not (p.lastbuttons & BT_CUSTOM2) then
				releaseMo(p)
			end
		end
	end
end)

local panimList = {
	[PA_IDLE] = S_BOOK_HOLD,
	[PA_EDGE] = S_BOOK_HOLD,
	[PA_WALK] = S_BOOK_HOLDWALK,
	[PA_RUN] = S_BOOK_HOLDWALK,
	[PA_JUMP] = S_BOOK_HOLDJUMP,
	[PA_SPRING] = S_BOOK_HOLDJUMP,
	[PA_FALL] = S_BOOK_HOLDFALL
}

addHook("PostThinkFrame", function()
	for p in players.iterate do
		if not (p.mo and p.mo.valid)
		or not skinCarry(p.mo.skin)
		or not p.bookgrab
		or not p.bookgrab.active then
			continue
		end
		
		if panimList[p.panim]
		and p.mo.state ~= panimList[p.panim] then
			local pa = p.panim
			p.mo.state = panimList[p.panim]
			p.panim = pa
		end
	end
end)

addHook("MobjThinker", function(mo)
	if not (mo.target and mo.target.valid)
	or not mo.target.health then
		P_RemoveMobj(mo)
		return
	end
	local tmo = mo.target
	
	local momang = R_PointToAngle2(0, 0, tmo.momx, tmo.momy)
	local rx, ry = P_ReturnThrustX(tmo, momang, tmo.radius), P_ReturnThrustY(tmo, momang, tmo.radius)
	local secx, secy = tmo.x+tmo.momy+rx, tmo.y+tmo.momy+ry
	local subsec = R_PointInSubsectorOrNil(secx, secy)
	if subsec and subsec.sector then
		local sec = subsec.sector
		for fof in sec.ffloors() do
			if not (fof.flags & FOF_EXISTS)
			or not (fof.flags & FOF_BLOCKOTHERS)
			or not (fof.flags & FOF_BUSTUP) then continue end
			
			local th, bh = fof.topheight, fof.bottomheight
			if fof.t_slope then
				th = P_GetZAt(fof.t_slope, secx, secy)
			end
			if fof.b_slope then
				bh = P_GetZAt(fof.b_slope, secx, secy)
			end
			
			if tmo.z+tmo.momz > th
			or tmo.z+tmo.height+tmo.momz < bh then continue end
			
			EV_CrumbleChain(sec, fof)
			P_DamageMobj(tmo, nil, mo.tracer)
			P_RemoveMobj(mo)
			return
		end
	end
	
	A_CapeChase(mo, 0, 0)
	mo.scale = tmo.scale
	mo.scalespeed = tmo.scalespeed
	mo.destscale = tmo.destscale
	mo.radius = tmo.radius
	mo.height = tmo.height
	
	if (tmo.flags & MF_NOGRAVITY) then -- would you preeeeetty please fall?
		tmo.momz = $+P_GetMobjGravity(tmo)
	end
	
	if P_IsObjectOnGround(tmo)
	and not (tmo.flags & MF_NOCLIPHEIGHT)
	or P_IsObjectOnGround(mo)
	and (tmo.flags & MF_NOCLIPHEIGHT) then
		if (tmo.flags & MF_NOCLIPHEIGHT) then
			tmo.momz = 0
		end
		P_RemoveMobj(mo)
		return
	end
end, MT_BOOK_THROWNHITBOX)

local function hurtCollide(box, mo)
	if box.z > mo.z+mo.height
	or mo.z > box.z+box.height then return end
	
	if not box.tracer
	or not box.target
	or mo == box.tracer
	or mo == box.target then return end
	
	local pmo = box.tracer
	local tmo = box.target
	
	if (mo.player and mo.player)
	and not shouldHurt(pmo, mo)
	or not (mo.flags & MF_SHOOTABLE)
	or (mo.flags & (MF_NOCLIPTHING|MF_NOCLIP)) then return end
	
	if deadlythrow.value
		P_KillMobj(mo, box, pmo)
		P_KillMobj(tmo, mo, pmo)
	else
		P_DamageMobj(mo, box, pmo)
		P_DamageMobj(tmo, mo, pmo)
	end
end

--addHook("MobjCollide", hurtCollide, MT_BOOK_THROWNHITBOX)
addHook("MobjMoveCollide", hurtCollide, MT_BOOK_THROWNHITBOX)