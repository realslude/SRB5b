
local cameraMo

addHook("ThinkFrame", function()
	if gamestate ~= GS_TITLESCREEN then
		cameraMo = nil
		return
	end
	
	if not (cameraMo and cameraMo.valid) then
		local aimingZ
		for mo in mobjs.iterate() do
			if mo.type == MT_BLUECRAWLA then
				local cmo = P_SpawnMobj(mo.x, mo.y, mo.z, MT_THOK)
				cmo.state = S_INVISIBLE
				cmo.tics = -1
				cmo.flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
				cmo.angle = mo.angle
				cameraMo = cmo
				P_RemoveMobj(mo)
			elseif mo.type == MT_REDCRAWLA then
				aimingZ = mo.z
				P_RemoveMobj(mo)
			end
		end
		if aimingZ == nil then
			cameraMo.srb5baiming = 0
		else
			cameraMo.srb5baiming = R_PointToAngle2(0, cameraMo.z, 0, aimingZ)
		end
	else
		P_TeleportCameraMove(camera, cameraMo.x, cameraMo.y, cameraMo.z)
		camera.angle = cameraMo.angle
		camera.aiming = cameraMo.srb5baiming
	end
end)

