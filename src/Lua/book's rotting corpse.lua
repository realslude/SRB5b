/*
-- i lov book corpse
-- (i dont)

-- i do however (slude)

freeslot("SPR_ROCO", "MT_BOOK_CORPSE")

mobjinfo[MT_BOOK_CORPSE] = {
	doomednum = -1,
	spawnhealth = 9999,
	spawnstate = S_INVISIBLE,
	deathstate = S_NULL,
	xdeathstate = S_NULL,
	deathsound = sfx_null,
	radius = 16*FU,
	height = 65*FU,
	flags = MF_SOLID|MF_PUSHABLE|MF_SHOOTABLE
}

mobjinfo[MT_BOOK_CORPSE].bookgrabbable = true -- also an example on letting an object be grabbable by book

local function initializeVars(p)
	p.bookcorpse = false
	
	--if not multiplayer and p.bookoldcorp return end
	if p.bookoldcorp return end
	
	p.bookoldcorp = {}
	p.bookcoldscale = 69420
	p.bookcoldflags = 0
end

addHook("PlayerSpawn", function(p)
	if not (p.mo and p.mo.valid)
	or p.mo.skin ~= "book" then return end
	
	initializeVars(p)
	
	if type(p.bookoldcorp) ~= "table"
		p.bookoldcorp = {}
	end
	
	if multiplayer return end
	
	for i, corp in ipairs(p.bookoldcorp) do
		local corp = p.bookoldcorp[i]
		local corpse = P_SpawnMobj(corp.x, corp.y, corp.z, MT_BOOK_CORPSE)
		corpse.target = p.mo
		corpse.scale = corp.scale
		corpse.flags = corp.flags[1]
		corpse.flags2 = corp.flags[2]
		corpse.eflags = corp.flags[3]
		corpse.color = corp.color
		--corpse.colorized = corp.colorized
	end
	if p.bookoldcorp[5]
		table.remove(p.bookoldcorp, 5)
	end
end)

addHook("MapChange", function()
	for p in players.iterate do
		if p.bookoldcorp then
			p.bookoldcorp = nil
		end
	end
end)

addHook("PlayerThink", function(p)
    if not (p.mo and p.mo.valid)
	or p.mo.skin ~= "book"
	or not G_CoopGametype() return end
	
	if p.bookcorpse == nil
	or p.bookoldcorp == nil then
		initializeVars(p)
	end
	
	if p.playerstate == PST_DEAD
	and P_IsObjectOnGround(p.mo)
	and p.mo.momz*P_MobjFlip(p.mo) <= 0
	and not p.bookcorpse
	and p.bookoldcorp ~= nil then
		p.bookcorpse = true
		local corpse = P_SpawnMobj(p.mo.x, p.mo.y, p.mo.z, MT_BOOK_CORPSE)
		corpse.flags2 = p.mo.flags2
		corpse.eflags = p.mo.eflags
		corpse.target = p.mo
		corpse.color = p.mo.color
		corpse.colorized = p.mo.colorized
		table.insert(p.bookoldcorp, 0, {
			x = corpse.x,
			y = corpse.y,
			z = corpse.z,
			scale = p.mo.scale,
			flags = {
				[1] = corpse.flags,
				[2] = corpse.flags2,
				[3] = corpse.eflags
			},
			color = corpse.color,
			colorized = corpse.colorized
		})
		p.mo.flags2 = $1|MF2_DONTDRAW
		p.mo.flags = $ & ~(MF_NOCLIP|MF_NOCLIPHEIGHT)
	end
end)

addHook("MobjSpawn", function(mo)
	mo.spritexscale = FixedMul($, skins["book"].highresscale)
	mo.spriteyscale = FixedMul($, skins["book"].highresscale)
	mo.sprite = SPR_ROCO
end, MT_BOOK_CORPSE)

addHook("MobjThinker", function(mo)
	if not G_CoopGametype() then -- let's not have corpses if we're not on a coop gametype :)
		P_RemoveMobj(mo)
		return
	end
	
	if (mo.target and mo.target.valid)
		mo.scale = mo.target.scale
		mo.target = nil
	end
end, MT_BOOK_CORPSE)

--addHook("ShouldDamage", function(mo, _, _, _, dmgtype)
--	if not (dmgtype & DMG_DEATHMASK) then return false end
--	
--	if dmgtype == DMG_CRUSHED then
--		if mo.height < FU/25 then return end
--		
--		mo.height = max($-FU, 0)
--		mo.spriteyscale = FixedMul( FixedDiv(FixedDiv(mo.height, mo.scale), mo.info.height), skins["book"].highresscale)
--		return false
--	end
end, MT_BOOK_CORPSE)*/