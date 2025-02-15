
-- Loading...

local cachedStuff = { -- this is only used on HUD rendering, shouldn't cause issues (?)
	patches = {},
	textPos = {}, -- i REALLY don't feel like typing expressionPos all the time i wanna access this :P
	strLen = {} -- idk why i cache this tbh :P
}

local function getPatch(v, name)
	if not (cachedStuff.patches[name] and cachedStuff.patches[name].valid) then
		cachedStuff.patches[name] = v.cachePatch(name)
	end
	return cachedStuff.patches[name]
end

-- are these necessary? probably not, idk :P
local function cacheVal(type, key, val)
	if type == nil then return end
	
	if not cachedStuff[type] then
		cachedStuff[type] = {}
	end
	
	cachedStuff[type][key] = val
	return cachedStuff[type][key]
end

local function getCachedVal(type, val)
	if not cachedStuff[type] then return end
	
	return cachedStuff[type][val]
end

-- add expressions here
-- if they're not in this table
-- then they aren't recognized
local expressionList = {
	normal = "TBNO",
	angry = "TBAN",
	annoyed = "TBAY"
}

-- expressions in text goes as follows:
-- {/expression} where expression is replaced
-- with the appropriate expression.
-- otherwise this is just a table with strings !!

-- {/number} will change the scroll speed
-- numbers higher than TICRATE (35) will have the same effect as TICRATE.
-- as otherwise i'd have to CHANGE stuff and I DONT WANT TO >:(
-- if you use 0 the game will close itself
-- that's a feature btw
local textList = {
	"{/normal}this is a test for the normal expression!",
	"{/angry}i'm angry (insert angry noises)",
	"{/annoyed}im anoy",
	"{/normal}i'm normal, {/angry}grrrrrr!! {/annoyed}i'm annoyed",
	"I've come to make an announcement: {/angry}Shadow the Hedgehog's a bitch-ass motherfucker, he pissed on my fucking wife. That's right, he took his hedgehog-fuckin' quilly dick out and he pissed on my fucking wife, and he said his dick was \"THIS BIG,\" and i said {/annoyed}\"that's disgusting,\" {/angry}so I'm making a callout post on my Twitter.com: Shadow the hedgehog, you've got a small dick. It's the size of this walnut except WAY smaller. And guess what? Here's what my dong looks like. [Explosion sounds] {/normal}That's right, baby. All points, no quills, no pillows - look at that, it looks like two balls and a bong. {/angry}He fucked my wife, so guess what, I'm gonna fuck the Earth. That's right, this is what you get: {/normal}MY SUPER LASER PISS!! Except I'm not gonna piss on the Earth, I'm gonna go higher; I'M PISSING ON THE MOON! {/angry}How do you like that, Obama?! I PISSED ON THE MOON, YOU IDIOT! {/normal}You have twenty-three hours before the piss D R O P L E T S hit the fucking Earth, {/angry}now get outta my fucking sight, before I piss on you too!",
	"{/3}testing different scroll speeds, {/35}so i'm going as fast as you can",
	"this is a lil test for\n new lines!!"
}

local xPos = 0

local function findIterate(str, pattern, start) -- baby's first iterate function
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

local shouldClose = false
local defTextSpd = 10 -- in letters per second
local function drawLoading(v, p, time, textNum, curPos)
	if not v
	or (splitscreen and p == secondarydisplayplayer) then return end
	
	v.drawFill()
	
	local dots = string.rep(".", (time/TICRATE)%4)
	SRB5b_drawString(v, 275*FU, 190*FU, FU/4, "Loading"+dots, V_SNAPTORIGHT|V_SNAPTOBOTTOM)
	
	time = tonumber($) or 0 -- make it so time is a number, if not then make it 0
	textNum = tonumber($) and min(max(tonumber($), 1), #textList) or 1 -- limit textNum to a number between 1 and the number of available texts.
	local curExpression = "normal" -- the current expression that tennis ball will use
	
	local loadingText = textList[textNum] -- get the text that should be displayed with all of the expressions and stuff
	local displayText = loadingText -- get the text that'll be displayed
	
	local cachedExp = getCachedVal("textPos", loadingText) -- i'd rather only use this function once, is that more optimized???
	local strExpList = cachedExp or {} -- the list of expressions in the string, being a table with tables containing where the expression starts and what expression it is
	if cachedExp == nil then
		local MATHstuff = 0
		for start, finish in findIterate(loadingText, "{/%w+}") do
			if not start
			or not finish then continue end -- JUST making sure!!
			
			local str = loadingText:sub(start+2, finish-1) -- so we have what's inside the {} excluding the / at the beggining
			local tableVal
			if expressionList[str] then
				tableVal = str
			elseif tonumber(str) then
				tableVal = tonumber(str)
			end
			strExpList[#strExpList+1] = {start-MATHstuff, tableVal}
			MATHstuff = $+(finish-(start-1))
		end
		
		cacheVal("textPos", loadingText, strExpList)
	end
	displayText = $:gsub("{/%w+}", "") -- MIGHT cause false positives if something FOR SOME REASON is inside {} and has a / at the beggining. SHOULDN'T happen though :P
	
	local length = getCachedVal("strLen", displayText) or cacheVal("strLen", displayText, displayText:len())
	if curPos < length then
		displayText = $:sub(1, curPos)
	end
	
	local textSpd = defTextSpd
	-- since we go through the string and add them to the table based
	-- on the string.find loop, then the order they're in the table
	-- should be based on when they show in the string (basically, the table order should be chronological)
	-- FUTURE PAC HERE: this also applies the text speed!!!!
	for _, val in ipairs(strExpList) do -- go through every expression -- Thing.
		if curPos >= val[1] then -- if we've gotten to the point where we can use the expression -- Thing.
			if expressionList[val[2]] then -- if it's an expression
				curExpression = val[2] -- then use it as such :P
			else
				textSpd = val[2] -- otherwise use it as the text speed
			end
			continue -- and go to the next expression -- Thing.
		end
		break -- if we're not supposed to use the expression then don't bother with the rest, since they're ahead of us
	end
	
	if textSpd == 0 then -- intentional Feature.
		shouldClose = true
	end
	
	local tbFrame = 1
	if curPos < length then
		tbFrame = (time/(TICRATE/textSpd or 1))%2 -- get tennis ball's animation frame based on what the time is
	end
	local patch = getPatch(v, expressionList[curExpression]+tbFrame) -- get tennis ball's sprite
	v.drawScaled(50*FU, 175*FU, FU/4, patch, V_SNAPTOLEFT|V_SNAPTOBOTTOM) -- draw TB
	--v.drawString(160, 50, displayText, 0, "center") -- and what he's saying!
	--SRB5b_drawString(v, 25*FU, 50*FU, FU/4, displayText, V_SNAPTOLEFT|V_SNAPTOBOTTOM)
	SRB5b_drawString(v, xPos, 50*FU, FU/4, displayText, V_SNAPTOLEFT|V_SNAPTOTOP)
	
	local add = time%(TICRATE/textSpd or 1) == 0 and 1 or 0
	return curPos+add -- best way to do it? i doubt it :P
end

local textPos = 1

local function initVar(p)
	return {
		enabled = false,
		time = 0,
		textNum = 1
	}
end

addHook("PlayerSpawn", function(p)
	if not (p.mo and p.mo.valid)
	or not SRB5b_skinCheck(p.mo.skin) then return end
	
	if p == displayplayer
	or splitscreen and p == secondarydisplayplayer then
		textPos = 1
	end
	p.srb5bloading = initVar(p)
end)

addHook("PlayerThink", function(p)
	if shouldClose then
		COM_BufInsertText(p, "quit")
	end
	
	if not (p.mo and p.mo.valid)
	or not SRB5b_skinCheck(p.mo.skin) then return end
	
	if not p.srb5bloading then
		p.srb5bloading = initVar(p)
	end
	local l = p.srb5bloading
	
	if (p.cmd.buttons & BT_ATTACK) -- DEBUG !!
	and not (p.lastbuttons & BT_ATTACK)
	and not multiplayer then
		l.enabled = true
		l.time = 0
		--l.textNum = P_RandomRange(1, #textList)
		l.textNum = 5
		if p == displayplayer
		or splitscreen and p == secondarydisplayplayer then -- LOCAL thing
			textPos = 1
		end
	end
	
	if not l.enabled then return end
	
	l.time = $+1
end)

addHook("HUD", function(v, p)
	if not (p.mo and p.mo.valid)
	or not SRB5b_skinCheck(p.mo.skin)
	or not p.srb5bloading
	or not p.srb5bloading.enabled then return end
	
	local l = p.srb5bloading
	
	local newPos = drawLoading(v, p, l.time, l.textNum, textPos)
	if not paused
	and not (menuactive and not netgame) then
		textPos = newPos
	end
end)