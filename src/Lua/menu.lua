/*
Future LUA for the menu code
will write titles and descriptions 

template;
cmd name: 
icon file name: 
title: 
Description: 

cmd name: book_grabanything
icon file name: MENU_GRABANYTHING
title: Grab anything
Description:
Allows the player to grab whatever "thing" that they want
(E.g. rings, bosses, trees, Braks electric shield /srs)

cmd name: book_grabweight
icon file name: MENU_GRABWEIGHT
title: Object weight
Description: 
Determines if the object that you are holding should have weight.
The larger the object the more weight it would have.
Weight affects how high your jump is

cmd name: book_grabbrain
icon file name: MENU_GRABBRAIN
title: Carried object AI
Description: 
Allows for the object that you are carrying to function normally
(E.g. a carried turret will still shoot)

cmd name: book_grabgrief
icon file name: MENU_GRABGRIEF
title: Player pickup
Description: 
Determines wherever players should be allowed to be carried

cmd name: book_deadlythrow
icon file name: MENU_DEADLYTHROW
title: Deadly throw
Description: 
Determines if the thrown object should instantly kill whatever it lands on

cmd name: book_throwaccel
icon file name: X
title: Throw acceleration
Description: 
Allows for the thrown object to be thrown faster
(If disabled then thrown objects will move similar to how they did pre-rewrite)

cmd name: book_keepinventory
icon file name: MENU_KEEPINVENTORY
title: Keep object
Description: 
Allows you to keep whatever item that you are holding between levels 

*/

-- hi guys it sme pac
-- this is the basis code for stuff
-- yeagh!!!
-- -pac (this is only really for future me so i know where stuff is and dont hate this code because i dont know where stuff is :D)

-- list of entries in the menu
-- so we can actually reference stuff
local entryList = {}

-- adds an entry to the menu
-- we don't really need anything fancy
-- since its all just command toggles
-- pretty much :P
-- pretty simple function but it does kind of
-- make the process less hard to follow or something
-- even if its kinda useless
-- idk
local function addEntry(icon, name, desc, cmd)
	entryList[#entryList+1] = {
		icon = icon,
		name = name,
		desc = desc,
		cmd = cmd
	}
end

-- im so good with names !!
local fontCacheThingIDontKnowIfThisFallsIntoCacheOrNot = {}

/*
	because we need croppabl fonts so it yknow,
	doesnt go outside the window :P

	TODO:
	 - make this draw
	 - thus make this not error
	 - actually do this :P
	 - its all the same thing but repeated over and over so it seems like i have a lot to do but instead only really have to just finish doing this already but i dont know what font to use so im leaving it to later
*/
local function drawFont(v, x, y, hscale, vscale, text, flags, colormap, sx, sy, w, h)
	if v == nil
	or x == nil
	or y == nil
	or not hscale
	or not vscale
	or text == nil
	or not w
	or not h then return end
	
	sx = $ or 0
	sy = $ or 0
	flags = $ or 0
	text = tostring($)
	
	for i = 1, #text do
		local patch
		if not fontCacheThingIDontKnowIfThisFallsIntoCacheOrNot[patch] then
			fontCacheThingIDontKnowIfThisFallsIntoCacheOrNot[patch] = v.cachePatch(patch)
		end
		patch = fontCacheThingIDontKnowIfThisFallsIntoCacheOrNot[$]
		
		v.drawCropped(
			x, y,
			hscale, vscale,
			patch, flags,
			colormap,
			sx, sy,
			w, h
		)
		x = $ + patch.width*hscale
	end
end

local function rightPrint(p, msg)
	if (p and p.valid) then
		CONS_Printf(p, msg)
	else
		print(msg)
	end
end

-- actually adding the shtuff to the list
-- to future self: search for spongebob movie to find this
for i = 1, 10 do
addEntry(
	"MENU_GRABANYTHING",
	"Grab anything",
	[[Allows the player to grab whatever "thing" that they want
(E.g. rings, bosses, trees, Braks electric shield /srs)]], -- big strings are really cool :D
	"book_grabanything"
)
end

COM_AddCommand("book_menu", function(p)
	if not (p and p.valid)
	or not (p.realmo and p.realmo.valid)
	or p.playerstate == PST_DEAD
	or p.mo.health <= 0 then
		rightPrint(p, "please be not dead and alive and in-game and all that stuff :D")
		return
	end
	
	p.fbmenu = not $
end)

addHook("PlayerThink", function(p) -- handles the menu-ing
	if not (p.realmo and p.realmo.valid)
	or p.playerstate == PST_DEAD
	or p.mo.health <= 0 then
		p.fbmenu = false
		return
	end
	
	if p.fbmenu == nil then
		p.fbmenu = false
	end
	
	
end)

local boxWidth = 160
local boxHeight = 100
addHook("HUD", function(v, p)
	if not p.fbmenu then return end
	
	v.drawFill(160-boxWidth/2, 100-boxHeight/2, boxWidth, boxHeight, 31|V_40TRANS)
end)