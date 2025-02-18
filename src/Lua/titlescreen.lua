
local hasChecked = false
local cameraMo
local spawnList

freeslot("MT_SRB5B_CHARSPAWN")
freeslot("SPR_YYBU", "S_SRB5B_YOYLEBUSH", "MT_SRB5B_YOYLEBUSH") -- never let me (slude) code cuz im gonna mess it up REAL good

mobjinfo[MT_SRB5B_CHARSPAWN] = {
	--$Title Character Spawn
	--$Sprite PLAYA0
	--$Category SRB5b
	--$Angled
	doomednum = 3202,
	spawnstate = S_INVISIBLE,
	radius = 16*FU,
	height = 48*FU,
	flags = MF_SCENERY
}

mobjinfo[MT_SRB5B_YOYLEBUSH] = {
	--$Title Yoyleberry bush
	--$Sprite YYBUA0
	--$Category SRB5b
	--$Angled
	doomednum = 3203,
	radius = 48*FU,
	height = 64*FU,
	flags = MF_SCENERY,
	spawnstate = S_SRB5B_YOYLEBUSH,
	duration = -1
}

states[S_SRB5B_YOYLEBUSH] = {
    sprite = SPR_YYBU,
    frame = A
}

local function getRandomSkin(blacklist)
	blacklist = $ or {}
	
	local rSkin = P_RandomRange(0, #skins-1)
	
	local blacklistLen = 0
	for _, val in pairs(blacklist) do
		blacklistLen = $+1
	end
	
	if blacklistLen == #skins then return end
	
	while blacklist[rSkin] do
		rSkin = P_RandomRange(0, #skins-1)
	end
	
	return rSkin
end

addHook("ThinkFrame", function()
	if gamestate ~= GS_TITLESCREEN then
		hasChecked = false
		cameraMo = nil
		spawnList = nil
		return
	end
	
	if not hasChecked then
		local aimingAngle
		local skinList = {}
		for mo in mobjs.iterate() do
			if mo.type == MT_BLUECRAWLA then
				local cmo = P_SpawnMobj(mo.x, mo.y, mo.z, MT_THOK)
				cmo.state = S_INVISIBLE
				cmo.tics = -1
				cmo.flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOTHINK
				cmo.angle = mo.angle
				cameraMo = cmo
				P_RemoveMobj(mo)
			elseif mo.type == MT_REDCRAWLA then
				aimingAngle = mo.angle
				P_RemoveMobj(mo)
			elseif mo.type == MT_SRB5B_CHARSPAWN then
				mo.state = S_PLAY_STND
				mo.tics = -1
				mo.frame = $|FF_ANIMATE
				
				local rSkin = getRandomSkin(skinList)
				
				if rSkin == nil then
					P_RemoveMobj(mo)
					continue
				end
				local skin = skins[rSkin]
				
				skinList[rSkin] = true
				mo.skin = skin.name
				mo.color = skin.prefcolor
				mo.radius = skin.radius
				mo.height = skin.height
				if skin.followitem
				and skin.followitem ~= MT_METALJETFUME then
					local fmo = P_SpawnMobjFromMobj(mo, -cos(mo.angle), -sin(mo.angle), 0, MT_THOK)
					fmo.angle = mo.angle
					fmo.tracer = mo
					mo.tracer = fmo
					fmo.skin = mo.skin
					fmo.flags = MF_NOGRAVITY|MF_SCENERY|MF_NOCLIP|MF_NOCLIPHEIGHT
					fmo.flags2 = $|MF2_LINKDRAW
					fmo.dispoffset = mobjinfo[skin.followitem].dispoffset
					fmo.state = mobjinfo[skin.followitem].spawnstate
					if skin.followitem == MT_TAILSOVERLAY then
						fmo.state = S_TAILSOVERLAY_STAND -- idk what this means i just copied from P_DoTailsOverlay :P
						fmo.movecount = -1
					end
				end
			end
		end
		cameraMo.srb5baiming = aimingAngle or 0
		hasChecked = true
	end
	
	if not (cameraMo and cameraMo.valid) then return end
	
	P_TeleportCameraMove(camera, cameraMo.x, cameraMo.y, cameraMo.z)
	camera.angle = cameraMo.angle
	camera.aiming = cameraMo.srb5baiming
end)

addHook("MobjThinker", function(mo)
	if (mo.tracer and mo.tracer.valid) then
		A_CapeChase(mo.tracer, 1)
	end
end, MT_SRB5B_CHARSPAWN)

addHook("HUD", function(v)
	v.drawScaled(200*FU, 25*FU, FU/8, v.cachePatch("BFDISRB2LOGO"), V_SNAPTOTOP|V_SNAPTORIGHT)
end, "title")