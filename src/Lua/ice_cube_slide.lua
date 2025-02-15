
-- lets ice cube slide
-- so she can uhh enter spin gaps or something idk

local function canSlide(p)
	if P_PlayerInPain(p)
	or p.playerstate == PST_DEAD
		return false
	end
	return true
end

freeslot(
	"SPR2_SLID", "S_ICECUBE_SLIDE",
	"SPR_ICFX", "S_ICECUBE_ICICLE",
	"MT_ICECUBE_FX"
)

states[S_ICECUBE_SLIDE] = {
	sprite = SPR_PLAY,
	frame = SPR2_SLID,
	tics = -1,
	nextstate = S_ICECUBE_SLIDE
}

states[S_ICECUBE_ICICLE] = {
	sprite = SPR_ICFX,
	frame = A,
	tics = TICRATE,
	nextstate = S_NULL
}

mobjinfo[MT_ICECUBE_FX] = {
	doomednum = -1,
	spawnhealth = 1,
	spawnstate = S_INVISIBLE,
	deathstate = S_NULL,
	xdeathstate = S_NULL,
	deathsound = sfx_s3k80
}

addHook("PlayerThink", function(p)
	if not (p.mo and p.mo.valid)
	or p.mo.skin ~= "icecube"
		if p.icsliding
			p.icsliding = false
		end
		return
	end
	
	if p.icsliding == nil
		p.icsliding = false
		p.icslide = {}
		p.icspinheld = 0
	end
	
	local s = p.icslide
	
	if (p.cmd.buttons & BT_SPIN)
		p.icspinheld = $+1
	else
		p.icspinheld = 0
	end
	
	if (p.icspinheld == 1 or (p.cmd.buttons & BT_SPIN) and (p.mo.eflags & MFE_JUSTHITFLOOR))
	and P_IsObjectOnGround(p.mo)
	and not p.icsliding
	and p.speed > p.normalspeed/4
	and canSlide(p)
		s.angle = R_PointToAngle2(0, 0, p.mo.momx, p.mo.momy)
		s.speed = p.speed
		p.icsliding = true
	end
	
	if p.icsliding
		if p.speed < FU/3
		or (p.pflags & PF_JUMPED)
		or not canSlide(p)
			p.icsliding = false
			p.spinitem = skins[p.mo.skin].spinitem
			if canSlide(p)
				if P_IsObjectOnGround(p.mo)
					p.mo.state = S_PLAY_RUN
				else
					p.mo.state = S_PLAY_JUMP
				end
			end
			return
		end
		
		if p.mo.state ~= S_ICECUBE_SLIDE
			p.mo.state = S_ICECUBE_SLIDE
		end
		
		p.powers[pw_strong] = STR_ATTACK|STR_ANIM
		P_ButteredSlope(p.mo)
		
		p.spinitem = MT_NULL
		if p.speed > FU
			p.pflags = $1|PF_SPINNING
			if not (p.cmd.sidemove or p.cmd.forwardmove)
				p.mo.friction = $/2
			end
		else
			P_InstaThrust(p.mo, 0, 0)
		end
		--p.drawangle = s.angle
	end
end)

addHook("MobjMoveBlocked", function(pmo)
	local p = pmo.player
	
	if pmo.skin ~= "icecube"
	or not p.icsliding
	or p.speed < 3*pmo.scale return end
	
	p.mo.z = $+1
	P_BounceMove(pmo)
	p.drawangle = R_PointToAngle2(0, 0, pmo.momx, pmo.momy)
	--P_Thrust(pmo, p.drawangle, p.speed/2)
	if p.speed > p.normalspeed*2
		P_InstaThrust(pmo, p.drawangle, p.speed)
	else
		P_InstaThrust(pmo, p.drawangle, FixedMul(p.speed, FixedDiv(11, 10)))
	end
	--P_Thrust(pmo, p.drawangle, 120*FU)
	
	S_StartSound(pmo, sfx_iceb)
	--S_StartSound(pmo, sfx_s3k80) -- this one maybe????
	for i = 1, 4 do
		local fx = P_SpawnMobj(pmo.x, pmo.y, pmo.z+p.height/2, MT_ICECUBE_FX)
		fx.eflags = pmo.eflags
		fx.state = S_ICECUBE_ICICLE
		fx.rollangle = FixedAngle(P_RandomRange(0, 359)*FU)
		fx.angle = R_PointToAngle2(0, 0, pmo.momx, pmo.momy)
		fx.scale = FixedMul(skins[pmo.skin].highresscale, pmo.scale)
		fx.color = p.mo.color
		fx.colorized = p.mo.colorized
		local add = FixedAngle(P_RandomRange(225, 450)*FU/10)
		if i > 2
			add = -$
		end
		P_InstaThrust(fx, fx.angle+add, P_RandomRange(2, 8)*pmo.scale)
		P_SetObjectMomZ(fx, P_RandomRange(5, 10)*FU)
	end
	return true
end, MT_PLAYER)

addHook("MobjThinker", function(mo)
	if not P_IsObjectOnGround(mo)
		mo.rollangle = $+ANG10
		mo.icfxmomz = mo.momz
		mo.tics = TICRATE
	elseif mo.icfxmomz
		if mo.icfxmomz > -5*FU
		and mo.icfxmomz < 5*FU
			P_KillMobj(mo)
			return
		end
		mo.momz = abs(mo.icfxmomz)/3
	end
end, MT_ICECUBE_FX)

addHook("MobjMoveBlocked", function(mo)
	P_BounceMove(mo)
end, MT_ICECUBE_FX)

addHook("PlayerHeight", function(p)
	if not (p.mo and p.mo.valid)
	or p.mo.skin ~= "icecube"
	or not p.icsliding return end
	
	return P_GetPlayerSpinHeight(p)
end)

addHook("PlayerCanEnterSpinGaps", function(p)
	if not (p.mo and p.mo.valid)
	or p.mo.skin ~= "icecube"
	or not p.icsliding return end
	
	return true
end)