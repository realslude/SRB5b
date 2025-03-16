
-- bubble's stuff
-- hooray!!
-- -pac

local function bubbleCheck(mo)
	return (mo and mo.valid) and mo.skin == "bubble"
end

sfxinfo[freeslot("sfx_yoycak")].caption = "Yoylecake!"

addHook("PlayerMsg", function(p, msgtype, _, msg)
	if not bubbleCheck(p.mo)
	or msgtype ~= 0
	or msg:lower() ~= "yoylecake" then return end
	
	S_StartSound(p.mo, sfx_yoycak)
	return true
end)

addHook("PlayerSpawn", function(p)
	if not bubbleCheck(p.mo) then return end
	
	p.bubblesprung = false
end)

addHook("PlayerThink", function(p)
	if not (p.mo and p.mo.valid) then return end
	
	if displayplayer
	and displayplayer == p then
		if p.mo.skin == "bubble" then
			hud.disable("rings")
			p.bubbleringhud = true
		elseif p.bubbleringhud
		or p.bubbleringhud == nil then
			p.bubbleringhud = false
			hud.enable("rings")
		end
	end
	
	if p.mo.skin ~= "bubble" -- if you're not bubble 
	or p.playerstate == PST_DEAD -- or you're dead
	or not p.mo.health -- in some way
	or p.exiting then return end -- or you're exiting the level, then don't proceed
	
	if (p.mo.eflags & MFE_SPRUNG) then
		p.bubblesprung = true
	elseif p.bubblesprung
	and P_IsObjectOnGround(p.mo) then
		p.bubblesprung = false
	end
	
	p.powers[pw_underwater] = 0 -- bubble can't drown :P
	p.powers[pw_spacetime] = 0
	
	local floatCheck = (p.mo.eflags & MFE_UNDERWATER) and not (p.mo.eflags & MFE_GOOWATER) and not (p.cmd.buttons & BT_SPIN) and not p.bubblesprung
	local gravFlip = (p.mo.eflags & MFE_VERTICALFLIP)
	if p.mo.momz then
		local grav = abs(P_GetMobjGravity(p.mo))
		local desiredGrav = FixedDiv(grav, FU+FU/4)
		
		if floatCheck then -- let us handle stuff on our own while underwater
			desiredGrav = 0
		end
		
		P_SetObjectMomZ(p.mo, grav-desiredGrav, true) -- i swear bubble had lower gravity,,,
	end
	
	if (p.mo.z+p.mo.height+p.mo.momz > p.mo.ceilingz and not gravFlip)
	or (p.mo.z+p.mo.momz < p.mo.floorz and gravFlip) then
		P_KillMobj(p.mo, nil, nil)
	end
	
	if floatCheck then
		P_SetObjectMomZ(p.mo, FU/5, true)
	end
end)

addHook("MobjDamage", function(pmo, inf, src, _, dmgtype)
	if not bubbleCheck(pmo) then return end
	
	P_KillMobj(pmo, inf, src, dmgtype)
	return true
end, MT_PLAYER)

addHook("MobjMoveBlocked", function(pmo, mo, line)
	if not bubbleCheck(pmo) then return end
	
	local inf
	if (mo and mo.valid)
		inf = mo
		if (mo.flags & MF_SHOOTABLE)
		and P_PlayerCanDamage(pmo.player, mo)
		or not mo.health then return end
		--or (mo.flags & MF_MONITOR) then return end
	end
	
	P_KillMobj(pmo, inf, inf)
end, MT_PLAYER)

/*addHook("MobjDeath", function(pmo)
	if not bubbleCheck(pmo) then return end
	
	
end, MT_PLAYER)*/