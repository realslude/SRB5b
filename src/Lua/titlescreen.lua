local titlepos = 300 --this defines the initial position of the graphics
local function mytitlescreen(v, player)
	local w = v.width()
	local h = v.height()
	
	local sky = v.cachePatch("TITLESKY")
	
	v.drawStretched(0, 0, FixedDiv(w, sky.width), FixedDiv(h, sky.height), sky, V_NOSCALEPATCH)
	v.draw(titlepos,10,v.cachePatch("LOGO")) --draw the LOGO graphic with titlepos as the x axis 
	v.draw(-titlepos,10,v.cachePatch("LOGO2")) --draw the LOGO2 graphic with negative titlepos as the x axis 
	v.draw(0,-titlepos,v.cachePatch("SRB2T")) --draw the SRB2T  graphic with negative titlepos as the y axis
	if titlepos > 0 --check if the titlepos is bigger than 0
	titlepos = $ - 1*titlepos/4 --subtract the titlepos value to move it to the middle of the screen, until the check on the line above stops it
	--the /4 makes an ease-out transition thing or something, i suck at math i just know it works
	end
end

hud.add(mytitlescreen, "title") --add the mytitlescreen function defined before (line 2)
addHook("PlayerThink", function(player) --this hook works when the player is in a level
	titlepos = 300 -- reset the titlepos to 300
end)