
-- hud stuff
-- yay :D

local cachedFont = {} -- so we can have more performance i think
local cachedLength = {}

local function getPatch(v, name)
	if not (cachedFont[name] and cachedFont[name].valid) then
		cachedFont[name] = v.cachePatch(name)
	end
	return cachedFont[name]
end

-- let's geet this string's width
-- should be kind of like v.levelTitleWidth or v.nameTagWidth
-- todo: use this in the loading thing :P
-- -pac
local function get5BWidth(v, str, scale) -- scale is optional
	if not v
	or str == nil then return end -- c'mon, at the very least give me the stuff to work with :P
	
	scale = $ or FU
	
	if not cachedLength[str] then -- don't calculate everything all the time, that could lag people out!!
		local len = str:len() -- literally just the drawing code, but without the drawing part :P
		local width = 0
		for i = 1, len do
			local curLet = str:byte(i, i)
			local ltr = getPatch(v, "5BFNT"+curLet)
			
			if curLet == 32
			or not v.patchExists("5BFNT"+curLet) then
				width = $+8
			else
				width = $+ltr.width
			end
		end
		cachedLength[str] = width
	end
	return cachedLength[str]*scale
end

local function findIterate(str, pattern, start) -- just copied it from the loading lua, since i wanna use it for the NEW LINES!!!!
	start = $ or 1
	local i = start-1
	local strLen = str:len()
	return function()
		i = $+1
		local foundVals = {string.find(str, pattern, i)}
		
		if i < strLen -- if i is lower than the string's length
		and foundVals[1] ~= nil then -- and something has been found
			if foundVals[2] ~= nil then -- if an end value has been given
				i = foundVals[2] -- set i to it
			end
			return unpack(foundVals) -- return what we found
		end
	end
end

local lineCache = {} -- WH y am i making this all seperate variables :(

local function draw5BString(v, x, y, scale, string, flags, alignment, wrap)
	if v == nil
	or x == nil
	or y == nil
	or string == nil return end
	
	scale = $ or FU
	flags = $ or 0
	alignment = $ or "left"
	string = tostring($)
	wrap = $ or false
	
	local curLine = 1
	local nList = {} -- stands for new (line) list
	local linesList = {1}
	if not lineCache[string] then
		for start, finish in findIterate(string, "\n") do
			nList[start+1] = true
			linesList[#linesList+1] = {start+1}
		end
		lineCache[string] = {nList, linesList}
	else
		nList = lineCache[string][1]
		linesList = lineCache[string][2]
	end
	string:gsub("\n", "")
	linesList[#linesList+1] = {-1}
	
	local prevX = x
	if alignment == "center" then
		prevX = $-get5BWidth(v, string:sub(1, linesList[2][1]), scale)/2
	end
	
	local len = string.len(string)
	local uY = y
	for i = 1, len do
		local curLet = string.byte(string, i, i)
		local ltr = getPatch(v, "5BFNT"+curLet)
		
		if nList[i] then
			curLine = $+1
			prevX = x
			uY = $+32*scale
			if alignment == "center" then
				prevX = $-get5BWidth(v, string:sub(linesList[curLine][1], linesList[curLine+1][1]), scale)/2
			end
		end
		
		if not v.patchExists("5BFNT"+curLet) then
			prevX = $+(8*scale)
		else
			v.drawScaled(prevX, uY, scale, ltr, flags|V_ADD)
			prevX = $+(ltr.width*scale)
		end
	end
	return prevX
end

rawset(_G, "SRB5b_getWidth", get5BWidth)
rawset(_G, "SRB5b_drawString", draw5BString)

local intertic = 0 -- i swear this will end up resynching somehow D:
local stagefailed
local intspec = {}

local hudinfoList = { "x", "y", "f" }
local srb5bLives = {x = 16, y = 176-12, f = V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER}
local prevlives
local hudActive = false
addHook("ThinkFrame", function()
	if not displayplayer
	and not (splitscreen and secondarydisplayplayer) return end
	
	intertic = 0
	stagefailed = nil
	intspec = {}
	local p = displayplayer or splitscreen and secondarydisplayplayer
	if not (p.mo and p.mo.valid) then return end
	
	if not SRB5b_skinCheck(p.mo.skin)
		if hudActive then
			if prevlives then
				for _, val in ipairs(hudinfoList) do
					hudinfo[HUD_LIVES][val] = prevlives[val]
				end
				prevlives = nil
			end
			hud.enable("coopemeralds")
			hudActive = false
		end
	elseif not hudActive then
		hud.disable("coopemeralds")
		prevlives = {}
		for _, val in ipairs(hudinfoList) do
			prevlives[val] = hudinfo[HUD_LIVES][val]
			hudinfo[HUD_LIVES][val] = srb5bLives[val]
		end
		hudActive = true
	end
end)

/*
	alright, soo, here's how you add a custom act thingie
	
	so, BookCustomAct is the global variable, right?
	it's a table with a bunch of Text & Numbers, those are your identifiers
	Numbers are in here for SPECIFICALLY binary, and work a bit differently
	you'll want to make it be a table too, that table having: (they all default to the automatic ones the hud has)
	
	num, this one's gotta be a number, changes the map number! (the "1." in "1. Greenflower act 1"
	name, the level's name, being a string, changes the well, level name (the "Greenflower" in "1. Greenflower act 1"
	act, changes the level's act, has to be a number, pretty self-explanatory too, (changes the "act 1" in "1. Greenflower act 1", if you don't want "act" change it to 0)
	
	alrighty, what about the Numbers are different from the Text?
	well, the ones in BookCustomAct are map numbers!! (A0 = 100 :D)
	inside that is a table with MORE numbers!
	the numbers represent a id to use in the offset x of the front side (in binary, udmf u just use the 1st numbered argument :P)
	the numbers r a table that has the stuff i said there
*/
rawset(_G, "BookCustomAct", {
	[33] = {
		[1] = {
			num = 1,
			name = "Greenflower",
			act = 1
		},
		[2] = {
			num = 2,
			name = "Greenflower",
			act = 2
		},
		[3] = {
			num = 3,
			name = "Techno Hill",
			act = 1
		},
		[4] = {
			num = 4,
			name = "Techno Hill",
			act = 2
		},
		[5] = {
			num = 5,
			name = "Castle Eggman",
			act = 1
		},
		[6] = {
			num = 6,
			name = "Castle Eggman",
			act = 2
		},
		[7] = {
			num = 7,
			name = "Castle Eggman",
			act = 3
		},
		[8] = {
			num = 8,
			name = "Red Volcano",
			act = 0
		}
	},
	[141] = { -- map 141 = map 5B
		[1] = {
			num = 1,
			name = "Time to Explore",
			act = 0
		},
		[2] = {
			num = 2,
			name = "First Danger",
			act = 0
		},
		[3] = {
			num = 3,
			name = "Pillar",
			act = 0
		},
		[4] = {
			num = 4,
			name = "Going Under",
			act = 0
		},
		[5] = {
			num = 6,
			name = "Landfill",
			act = 0
		},
		[6] = {
			num = 53,
			name = "I am sorry",
			act = 0
		}
	}
})

addHook("MapLoad", function(id)
	for p in players.iterate do
		if p.starpostnum then continue end
		
		p.bookcustomtext = BookCustomAct[id] and BookCustomAct[id][0] or -1
	end
end)

local function setText(p, num)
	if tonumber(num) ~= nil then
		p.bookcustomtext = BookCustomAct[gamemap] and BookCustomAct[gamemap][tonumber(num)] or -1
	else
		p.bookcustomtext = BookCustomAct[num]
	end
end

addHook("LinedefExecute", function(line, pmo, sec)
	if not (pmo.player and pmo.player.valid) then return end
	
	local p = pmo.player
	local num = line.frontside.textureoffset/FU
	if udmf then
		num = line.stringargs[0] or line.args[0]
	end
	setText(p, num)
end, "5BACT")

local FDsector = {
	[146] = 2,
	[598] = 8,
	[515] = 2,
	[426] = 3,
	[428] = 4,
	[429] = 5,
	[430] = 6,
	[410] = 7
}

addHook("PlayerThink", function(p)
	if gamemap ~= 33
	or mapheaderinfo[gamemap].lvlttl ~= "Final Demo" then return end
	
	if p.bookcustomtext == -1 then
		setText(p, 1)
	elseif FDsector[p.mo.subsector.sector.tag] then
		setText(p, FDsector[p.mo.subsector.sector.tag])
	end
end)

local function IsSpecialStage(mapnum) -- unnecessarily translate G_IsSpecialStage to lua, because why not? also gives you which special stage you're in
	mapnum = $ ~= nil and $ or gamemap
	if (modeattacking)
		return false;
	end
	
	if (mapnum >= sstage_start and mapnum <= sstage_end)
		return true, mapnum-sstage_start+1;
	end
	
	if (mapnum >= smpstage_start and mapnum <= smpstage_end)
		return true, mapnum-smpstage_start+1;
	end

	return false;
end

addHook("HUD", function(v, p)
	v.drawString(160, 0, "SRB5b Discord Link:", V_SNAPTOTOP|V_30TRANS|V_ALLOWLOWERCASE, "small-center")
	v.drawString(160, 4, "discord.gg/PZufdewhH5", V_SNAPTOTOP|V_30TRANS|V_ALLOWLOWERCASE, "small-center")
	
	if not (p.mo and p.mo.valid)
	or not SRB5b_skinCheck(p.mo.skin) then return end -- gotta make this a function soon -- update: i did it!!
	
	--draw5BString(v, 0, 0, FU/2, "new line test\nthis is a new line\nheres another one\nand another\nlook, i'm trying to test\nthe new lines ok?\notherwise, how will i know\nthat this\nworks properly")
	
	local name = mapheaderinfo[gamemap].lvlttl
	if name == "" then name = "undefined" end
	local mnum = ((gamemap ~= tutorialmap) and gamemap) or 0
	local actnum = mapheaderinfo[gamemap].actnum
	
	local isSS, SSNum = IsSpecialStage() -- SS = Special Stage
	if isSS then
		mnum = "SS "+SSNum
	end
	
	if p.bookcustomtext
	and type(p.bookcustomtext) == "table" then
		local cText = p.bookcustomtext -- custom text
		
		if cText.num
		and tonumber(cText.num) ~= nil then
			mnum = tonumber(cText.num)
		end
		
		if cText.name
		and tostring(cText.name) then
			name = tostring(cText.name)
		end
		
		if cText.act
		and tonumber(cText.act) then
			actnum = tonumber(cText.act)
		end
	end
	
	local mstr = (G_CoopGametype() and mnum+". ") or ""
	local actstr = ((actnum ~= 0) and name ~= "undefined" and (" act "+actnum)) or ""
	
	draw5BString(v, 4*FU, 184*FU, FU/2, mstr+name+actstr, V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER|V_HUDTRANS)
end, "game")

local cachedToken
local emeraldPos = {
	[0] = {
		x = (BASEVIDWIDTH/2)-8,
		y = (BASEVIDHEIGHT/3)-32,
	},
	[1] = {
		x = (BASEVIDWIDTH/2)-8+24,
		y = (BASEVIDHEIGHT/3)-16
	},
	[2] = {
		x = (BASEVIDWIDTH/2)-8+24,
		y = (BASEVIDHEIGHT/3)+16
	},
	[3] = {
		x = (BASEVIDWIDTH/2)-8,
		y = (BASEVIDHEIGHT/3)+32
	},
	[4] = {
		x = (BASEVIDWIDTH/2)-8-24,
		y = (BASEVIDHEIGHT/3)+16
	},
	[5] = {
		x = (BASEVIDWIDTH/2)-8-24,
		y = (BASEVIDHEIGHT/3)-16
	},
	[6] = {
		x = (BASEVIDWIDTH/2)-8,
		y = (BASEVIDHEIGHT/3)
	}
}

local emeraldslist = {
	[0] = SKINCOLOR_GREEN,
	[1] = SKINCOLOR_SIBERITE,
	[2] = SKINCOLOR_SAPPHIRE,
	[3] = SKINCOLOR_SKY,
	[4] = SKINCOLOR_TOPAZ,
	[5] = SKINCOLOR_FLAME,
	[6] = SKINCOLOR_SLATE,
	[7] = SKINCOLOR_BLACK
}

addHook("HUD", function(v)
	if (netgame or multiplayer) and not (gametyperules & GTR_CAMPAIGN)
	or not displayplayer
	or not SRB5b_skinCheck(skins[displayplayer.skin].name) then return end
	
	if not (cachedToken and cachedToken.valid) then
		cachedToken = v.cachePatch("WINTOKEN")
	end
	local patch = cachedToken
	for i = 0, 6 do
		if not (emeralds & 1<<i) then continue end
		
		local x, y = emeraldPos[i].x, emeraldPos[i].y
		if (netgame or multiplayer) then
			x, y = 20 + (i * 10), 7
		end
		v.drawScaled(x*FU, y*FU, FU, patch, 0, v.getColormap(TC_DEFAULT, emeraldslist[i]))
	end
end, "scores")

local function P_GetNextEmerald()
	if (gamemap >= sstage_start and gamemap <= sstage_end)
		return (gamemap - sstage_start);
	end
	if (gamemap >= smpstage_start or gamemap <= smpstage_end)
		return (gamemap - smpstage_start);
	end
	return 0;
end

local function handleSpec(v, spec)
	if spec == nil then
		spec = {}
	end
	
	// emerald bounce
	if (intertic <= 1)
	or spec.emeraldbounces == nil
	or spec.emeraldmomy == nil
	or spec.emeraldy == nil
		spec.emeraldbounces = 0;
		spec.emeraldmomy = 20;
		spec.emeraldy = -40;
	elseif (P_GetNextEmerald() < 7)
		if not (stagefailed)
			if (spec.emeraldbounces < 3)
				spec.emeraldmomy = $+1
				spec.emeraldy = $+spec.emeraldmomy;
				if (spec.emeraldy > 74)
					spec.emeraldbounces = $+1;
					spec.emeraldmomy = -($/2);
					spec.emeraldy = 74;
				end
			end
		else
			if (spec.emeraldy < (v.height/v.dupy)+16)
				spec.emeraldmomy = $+1
				spec.emeraldy = $+spec.emeraldmomy;
			end
			if (spec.emeraldbounces < 1 and spec.emeraldy > 74)
				spec.emeraldbounces = $+1;
				spec.emeraldmomy = -($/2);
				spec.emeraldy = 74;
			end
		end
	end
	
	return spec
end

local function drawEmerald(v, spec)
	local drawthistic = not (All7Emeralds(emeralds) and (intertic & 1));
	local emeraldx = 152 - 3*28;
	local em = P_GetNextEmerald();
	
	if not (cachedToken and cachedToken.valid) then
		cachedToken = v.cachePatch("WINTOKEN")
	end
	local patch = cachedToken
	if (em == 7)
		if not (stagefailed)
			local adjust = 2*(sin(FixedAngle((intertic + 1)<<(FRACBITS-4))));
			v.drawScaled((152<<FRACBITS)+(patch.leftoffset<<FRACBITS), (74<<FRACBITS) - adjust + (patch.topoffset<<FRACBITS), scale, patch, 0, v.getColormap("sonic", emeraldslist[em]));
		end
	elseif (em < 7)
		if (drawthistic)
			for i = 0, 7 do
				if ((i != em) and (emeralds & (1 << i)))
					v.draw(emeraldx+patch.leftoffset, 74+patch.topoffset, patch, 0, v.getColormap("sonic", emeraldslist[i]));
				end
				emeraldx = $+28;
			end
		end

		emeraldx = 152 + (em-3)*28;

		if (intertic > 1)
			if (stagefailed and spec.emeraldy < (v.height/v.dupy)+16)
				emeraldx = $+intertic - 6;
			end

			if (drawthistic)
				v.draw(emeraldx+patch.leftoffset, spec.emeraldy+patch.topoffset, patch, 0, v.getColormap("sonic", emeraldslist[em]));
			end
		end
	end
end

addHook("IntermissionThinker", function(sf)
	if not consoleplayer then return end
	local p = consoleplayer
	
	intertic = $+1
	stagefailed = sf
	
	if not SRB5b_skinCheck(p.skin)
	or not IsSpecialStage() then
		if p.bookinthud then
			--hud.enable("intermissiontitletext")
			hud.enable("intermissionemeralds")
			p.bookinthud = false
		end
	elseif not p.bookinthud then
		--hud.disable("intermissiontitletext")
		hud.disable("intermissionemeralds")
		p.bookinthud = true
	end
end)

addHook("HUD", function(v)
	if not consoleplayer then return end
	local p = consoleplayer
	
	if not SRB5b_skinCheck(p.skin)
	or not IsSpecialStage() then return end
	
	intspec = handleSpec(v, $)
	drawEmerald(v, intspec)
end, "intermission")