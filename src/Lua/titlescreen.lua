
local hasChecked = false
local cameraMo
local spawnList

freeslot("MT_SRB5B_CHARSPAWN")

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

local function getRandomSkin(blacklist)
	blacklist = $ or {}
	
	local rSkin = P_RandomRange(0, #skins)
	
	local blacklistLen = 0
	for _, val in pairs(blacklist) do
		blacklistLen = $+1
	end
	
	if blacklistLen == #skins then
		rSkin = nil
	else
		while blacklist[rSkin] do
			rSkin = P_RandomRange(0, #skins)
		end
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
				mo.frame = $|FF_ANIMATE
				
				local rSkin = getRandomSkin(skinList)
				
				if rSkin == nil then
					P_RemoveMobj(mo)
					continue
				end
				
				skinList[rSkin] = true
				mo.skin = rSkin
				mo.color = skins[rSkin].prefcolor
				mo.radius = skins[rSkin].radius
				mo.height = skins[rSkin].height
				if skins[rSkin].followmobj
				and skins[rSkin.followmobj] ~= MT_METALJETFUME then
					local ftype = mobjinfo[skins[rSkin].followmobj]
					local fmo = P_SpawnMobjFromMobj(mo, -cos(mo.angle), -sin(mo.angle), 0, MT_THOK)
					fmo.tracer = mo
					fmo.flags = MF_NOGRAVITY|MF_SCENERY|MF_NOCLIP|MF_NOCLIPHEIGHT
					fmo.flags2 = $|MF2_LINKDRAW
					fmo.state = ftype.spawnstate
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

