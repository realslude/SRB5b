
-- boxes
-- or crates
-- i ´dont knw
-- from bfdia5b
-- yay
-- -Pacola

freeslot("SPR_5BBX", "MT_BOOK_WOODBOX", "MT_BOOK_METALBOX", "MT_BOOK_BOXDUMMY")

mobjinfo[MT_BOOK_WOODBOX] = {
	--$Title Wooden Box
	--$Sprite 5BBXA0
	--$Category Book/BFDIA 5b
	--$Angled
	doomednum = 3200,
	spawnhealth = 1,
	spawnstate = S_INVISIBLE,
	deathstate = S_NULL,
	xdeathstate = S_NULL,
	deathsound = sfx_null,
	radius = 32*FU,
	height = 64*FU,
	flags = MF_SOLID
}

mobjinfo[MT_BOOK_METALBOX] = {
	--$Title Metal Box
	--$Sprite 5BBXB0
	--$Category Book/BFDIA 5b
	--$Angled
	doomednum = 3201,
	spawnhealth = 1,
	spawnstate = S_INVISIBLE,
	deathstate = S_NULL,
	xdeathstate = S_NULL,
	deathsound = sfx_null,
	radius = 64*FU,
	height = 128*FU,
	flags = MF_SOLID
}

mobjinfo[MT_BOOK_WOODBOX].bookgrabbable = true
mobjinfo[MT_BOOK_WOODBOX].book3dbox = true
mobjinfo[MT_BOOK_METALBOX].bookgrabbable = true
mobjinfo[MT_BOOK_METALBOX].book3dbox = true

mobjinfo[MT_BOOK_BOXDUMMY] = {
	doomednum = -1,
	spawnhealth = 1,
	spawnstate = S_INVISIBLE,
	deathstate = S_NULL,
	xdeathstate = S_NULL,
	deathsound = sfx_null,
	flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
}

/*addHook("PlayerSpawn", function(p) -- Debug feature to test boxes.
	local x = cos(p.mo.angle)
	local y = sin(p.mo.angle)
	P_SpawnMobj(p.mo.x+128*x, p.mo.y+128*y, p.mo.z, MT_BOOK_WOODBOX)
	P_SpawnMobj(p.mo.x+256*x, p.mo.y+256*y, p.mo.z, MT_BOOK_METALBOX)
end)*/

addHook("MobjSpawn", function(mo)
	mo.boxdummies = {}
	mo.scale = FU/2
	for i = 1, 4 do
		local d = P_SpawnMobj(mo.x, mo.y, mo.z, MT_BOOK_BOXDUMMY)
		d.scale = mo.scale
		d.renderflags = $1|RF_PAPERSPRITE
		d.sprite = SPR_5BBX
		d.frame = A
		d.target = mo
		d.bboxnum = i
		d.bboxpaper = true
		table.insert(mo.boxdummies, 0, d)
	end
	for i = 0, 1 do
		local d = P_SpawnMobj(mo.x, mo.y, mo.z, MT_BOOK_BOXDUMMY)
		d.scale = mo.scale
		d.spriteyoffset = -64*d.scale
		d.renderflags = $1|RF_FLOORSPRITE|RF_NOSPLATBILLBOARD
		d.sprite = SPR_5BBX
		d.frame = A
		d.target = mo
		d.bboxnum = i
		table.insert(mo.boxdummies, 0, d)
	end
	mo.radius = FixedMul(mo.info.radius, mo.scale)
	mo.height = FixedMul(mo.info.height, mo.scale)
end, MT_BOOK_WOODBOX)

addHook("MobjSpawn", function(mo) -- i love copy and paste
	mo.boxdummies = {}
	mo.scale = FU/2
	for i = 1, 4 do
		local d = P_SpawnMobj(mo.x, mo.y, mo.z, MT_BOOK_BOXDUMMY)
		d.scale = mo.scale
		d.renderflags = $1|RF_PAPERSPRITE
		d.sprite = SPR_5BBX
		d.frame = B
		d.target = mo
		d.bboxnum = i
		d.bboxpaper = true
		table.insert(mo.boxdummies, 0, d)
	end
	for i = 0, 1 do
		local d = P_SpawnMobj(mo.x, mo.y, mo.z, MT_BOOK_BOXDUMMY)
		d.scale = mo.scale
		d.spriteyoffset = -128*d.scale
		d.renderflags = $1|RF_FLOORSPRITE|RF_NOSPLATBILLBOARD
		d.sprite = SPR_5BBX
		d.frame = B
		d.target = mo
		d.bboxnum = i
		table.insert(mo.boxdummies, 0, d)
	end
	mo.radius = FixedMul(mo.info.radius, mo.scale)
	mo.height = FixedMul(mo.info.height, mo.scale)
end, MT_BOOK_METALBOX)

addHook("MobjThinker", function(mo)
	if not (mo.target and mo.target.valid) P_RemoveMobj(mo) return end
	
	local b = mo.target
	if mo.bboxpaper	
		if (b.flags & MF_NOTHINK)
			b.angle = mo.angle+ANGLE_90*(mo.bboxnum-1)
		else
			mo.angle = b.angle+ANGLE_90*(mo.bboxnum-1)
		end
		
		local x = cos(b.angle+ANGLE_90*mo.bboxnum)
		local y = sin(b.angle+ANGLE_90*mo.bboxnum)
		P_MoveOrigin(mo, b.x+FixedMul(b.radius, x), b.y+FixedMul(b.radius, y), b.z)
	else
		mo.angle = b.angle
		P_MoveOrigin(mo, b.x, b.y, b.z+b.height*mo.bboxnum)
	end
end, MT_BOOK_BOXDUMMY)

local function boxthing(pmo, b)
	if not b.info.book3dbox
	or not b.bookthrown return end
	
	if b.z > pmo.z+pmo.height
	or pmo.z > b.z+b.height return end
	
	return false
end

addHook("MobjCollide", boxthing, MT_PLAYER)
addHook("MobjMoveCollide", boxthing, MT_PLAYER)