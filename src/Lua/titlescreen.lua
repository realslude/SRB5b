
local hasChecked = false
local cameraMo

-- charspawn stuff
local randomAmount = 0
local skinList = {}

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
	spawnstate = S_SRB5B_YOYLEBUSH
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
		randomAmount = 0
		return
	end
	
	if not hasChecked then
		local aimingAngle
		skinList = {}
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
				
				local sec = mo.subsector and mo.subsector.sector or nil
				local forceSkin
				if (sec and sec.valid) then
					for i = 0, #sec.lines do
						local line = sec.lines[i]
						if not (line and line.valid)
						or line.frontsector ~= sec then continue end
						
						for ii = 0, #skins-1 do
							if line.text == nil -- line.text only exists if linedef's action is 331 or 443 (kinda sucks since this is for binary but ehhh) -pac
							or skins[ii].name ~= tostring(line.text):lower() then continue end
							
							randomAmount = $+1
							forceSkin = ii
							break 2
						end
						break
					end
				end
				if forceSkin ~= nil then
					mo.srb5bisrandom = true
					mo.srb5bskin = forceSkin
				end
				
				mo.srb5bready = false
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
	
	
	if not mo.srb5bisrandom
	and randomAmount > 0 then return end
	
	if not mo.srb5bready
	and mo.srb5bready ~= nil then
		if mo.srb5bskin == nil then
			mo.srb5bskin = getRandomSkin(skinList)
		end
		
		if mo.srb5bskin == nil then
			P_RemoveMobj(mo)
			return
		end
		
		local skin = skins[mo.srb5bskin]
		
		skinList[mo.srb5bskin] = true
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
				fmo.state = S_TAILSOVERLAY_STAND
				fmo.movecount = -1 -- idk what this means i just copied from P_DoTailsOverlay :P
			end
		end
		
		mo.srb5bready = true
		if mo.srb5bisrandom then
			randomAmount = $-1
		end
	end
	
	if (mo.tracer and mo.tracer.valid) then
		A_CapeChase(mo.tracer, 1, -FU)
	end
end, MT_SRB5B_CHARSPAWN)

addHook("HUD", function(v)
	v.drawScaled(200*FU, 25*FU, FU/8, v.cachePatch("BFDISRB2LOGO"), V_SNAPTOTOP|V_SNAPTORIGHT)
end, "title")