
-- handles animation states
-- should hopefully make it easier to do Stuff
-- based entirely on SPR2s and not actual states
-- -pac

local function bubbleCheck(mo)
	return (mo and mo.valid) and mo.skin == "bubble"
end

rawset(_G, "BubbleStates", {})

local function stndLimbs(p, mo, limb)
	limb.frame = A
	limb.angleOff = 0
end

local function stndFace(p, mo, eyes)
	eyes.frame = A|FF_PAPERSPRITE
	eyes.angleOff = 0
end

BubbleStates[SPR2_STND] = {
	armFunc = stndLimbs,
	legFunc = stndLimbs,
	faceFunc = stndFace
}

--bubbleFrame
local function walkArm(p, mo, arm, key)
	--arm.frame = (B+(((mo.bubbleFrame+20*(key-1))/2)%T))|FF_PAPERSPRITE
	arm.frame = (B + ((mo.bubbleFrame + 10 * (key-1)) % (U)))|FF_PAPERSPRITE
	arm.angleOff = ANGLE_90*(key == 1 and -1 or 1)
end

-- I
local function walkLeg(p, mo, leg, key)
	leg.frame = (B + ((mo.bubbleFrame + 7 * (key-1)) % (O)))
	leg.angleOff = ANGLE_45*(key-1)
end

BubbleStates[SPR2_WALK] = {
	armFunc = walkArm,
	legFunc = walkLeg
}