
-- woahh
-- she's THREE D!!!
-- -pac

local function bubbleCheck(mo)
	return (mo and mo.valid) and mo.skin == "bubble"
end

freeslot("MT_BUBBLE_LIMBHANDLER")

local limbFlags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOBLOCKMAP|MF_NOGRAVITY

mobjinfo[MT_BUBBLE_LIMBHANDLER] = {
	doomednum = -1,
	spawnstate = S_INVISIBLE,
	deathstate = S_NULL,
	flags = limbFlags
}

local function initLimbs(p)
	local mo = p.mo
	
	local limbTable = {}
	
	for i = 1, 2 do
		local arm = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_THOK)
		arm.state = S_INVISIBLE
		arm.skin = "bubble"
		arm.sprite = SPR_PLAY
		arm.sprite2 = SPR2_TAL0
		arm.frame = A
		arm.scale = mo.scale*2
		arm.flags = limbFlags
		limbTable[#limbTable+1] = arm
	end
	for i = 1, 2 do
		local leg = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_THOK)
		leg.state = S_INVISIBLE
		leg.skin = "bubble"
		leg.sprite = SPR_PLAY
		leg.sprite2 = SPR2_TAL1
		leg.frame = A
		leg.scale = mo.scale*2
		leg.flags = limbFlags
		--if i == 1 then leg.renderflags = $1|RF_HORIZONTALFLIP end
		limbTable[#limbTable+1] = leg
	end
	
	local eyes = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_THOK)
	eyes.state = S_INVISIBLE
	eyes.skin = "bubble"
	eyes.sprite = SPR_PLAY
	eyes.sprite2 = SPR2_TAL2
	eyes.frame = A|FF_PAPERSPRITE
	eyes.flags = limbFlags
	limbTable[#limbTable+1] = eyes
	local mouth = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_THOK)
	mouth.state = S_INVISIBLE
	mouth.skin = "bubble"
	mouth.sprite = SPR_PLAY
	mouth.sprite2 = SPR2_TAL3
	mouth.frame = C|FF_PAPERSPRITE
	mouth.flags = limbFlags
	limbTable[#limbTable+1] = mouth
	return limbTable
end

local bubbleTrans = FF_TRANS20

addHook("PostThinkFrame", function()
	for p in players.iterate do
		if not bubbleCheck(p.mo) then
			if p.bubbletransparency then
				p.mo.frame = $ & ~bubbleTrans
				p.bubbletransparency = false
			end
			continue
		end
		
		if not (p.mo.frame & bubbleTrans) then
			p.mo.frame = $1|bubbleTrans
			p.bubbletransparency = true
		end
	end
end)

addHook("MobjRemoved", function(mo)
	if mo.bubblelimbs then
		for _, limb in ipairs(mo.bubblelimbs) do
			if (limb and limb.valid) then
				P_RemoveMobj(limb)
			end
		end
	end
end, MT_BUBBLE_LIMBHANDLER)

local keyList = {
	"arm",
	"arm",
	"leg",
	"leg",
	"eyes",
	"mouth"
}

rawset(_G, "BubbleAnim", {})

local spr2Conv = {
	["arm"] = SPR2_TAL0,
	["leg"] = SPR2_TAL1,
	["eyes"] = SPR2_TAL2,
	["mouth"] = SPR2_TAL3
}

addHook("PostThinkFrame", function()
	for p in players.iterate do
		local mo = p.followmobj
		
		if not bubbleCheck(p.mo)
		or not (mo and mo.valid) then continue end
		
		if not mo.bubblelimbs then
			mo.bubblelimbs = initLimbs(p)
		end
		local pmo = p.mo
		
		mo.radius = pmo.radius
		mo.height = pmo.height
		mo.scale = pmo.scale
		if mo.prevSpr2 ~= p.mo.sprite2 then
			mo.bubbleFrame = A
		end
		
		if (pmo.frame & FF_ANIMATE)
		and pmo.anim_duration == 1
		or not (pmo.frame & FF_ANIMATE)
		and pmo.tics == 1
		and states[pmo.state].nextstate == pmo.state then
			mo.bubbleFrame = $+1
		end
		
		local spr2Anim = BubbleStates[p.mo.sprite2] or BubbleStates[SPR2_STND]
		local bubbleOffset = FixedMul(43*skins[pmo.skin].highresscale, mo.scale)
		--local bubbleOffset = 43*(mo.scale/2)
		local flags2Thing = (pmo.flags2 & MF2_DONTDRAW)
		
		local flipNum = P_MobjFlip(mo)
		local flip = flipNum == -1 and true or false
		local bottomZ = flip and pmo.z-bubbleOffset or pmo.z
		for i = 1, 2 do
			local arm = mo.bubblelimbs[i]
			if spr2Anim.armFunc then
				spr2Anim.armFunc(p, mo, arm, i)
			end
			
			local ang = i == 1 and ANGLE_90 or -ANGLE_90
			local x = cos(p.drawangle+ang)
			local y = sin(p.drawangle+ang)
			
			local dist = mo.radius-7*mo.scale
			arm.angle = p.drawangle+ang+(arm.angleOff or 0)
			arm.sprite = SPR_PLAY
			arm.sprite2 = SPR2_TAL0
			arm.scale = mo.scale*2
			arm.eflags = mo.eflags
			arm.flags2 = flags2Thing
			P_MoveOrigin(arm, pmo.x+FixedMul(dist, x), pmo.y+FixedMul(dist, y), bottomZ+(mo.height/3+bubbleOffset)*flipNum)
		end
		for i = 1, 2 do
			local leg = mo.bubblelimbs[i+2]
			if spr2Anim.legFunc then
				spr2Anim.legFunc(p, mo, leg, i)
			end
			
			local mul = i == 2 and -1 or 1
			local ang = ANGLE_90*mul
			local drawang = ANGLE_45*mul
			local x = cos(p.drawangle+ang)
			local y = sin(p.drawangle+ang)
			leg.angle = p.drawangle+drawang+(leg.angleOff or 0)
			leg.sprite = SPR_PLAY
			leg.sprite2 = SPR2_TAL1
			local dist = mo.radius/2-6*mo.scale
			leg.scale = mo.scale*2
			leg.eflags = mo.eflags
			leg.flags2 = flags2Thing
			P_MoveOrigin(leg, pmo.x+FixedMul(dist, x), pmo.y+FixedMul(dist, y), bottomZ)
		end
		
		for i = 1, 2 do
			local face = mo.bubblelimbs[i+4]
			if spr2Anim.faceFunc then
				spr2Anim.faceFunc(p, mo, face)
			end
			local limbType = keyList[i+4]
			if limbType == "eyes"
			and spr2Anim.eyesFunc then
				spr2Anim.eyesFunc(p, mo, face)
			elseif limbType == "mouth"
			and spr2Anim.mouthFunc then
				spr2Anim.mouthFunc(p, mo, face)
			end
			
			local x = cos(p.drawangle)
			local y = sin(p.drawangle)
			local dist = mo.radius-5*mo.scale
			face.angle = p.drawangle+ANGLE_90+(face.angleOff or 0)
			face.sprite = SPR_PLAY
			face.sprite2 = limbType == "eyes" and SPR2_TAL2 or SPR2_TAL3
			face.scale = mo.scale
			face.eflags = mo.eflags
			face.flags2 = flags2Thing
			if (p == displayplayer
				or splitscreen and p == secondarydisplayplayer)
			and not camera.chase then
				face.flags2 = $1|MF2_DONTDRAW
			end
			P_MoveOrigin(face, pmo.x+FixedMul(dist, x), pmo.y+FixedMul(dist, y), bottomZ+(mo.height/2+bubbleOffset-10*mo.scale)*flipNum)
		end
		
		mo.prevSpr2 = p.mo.sprite2
	end
end)