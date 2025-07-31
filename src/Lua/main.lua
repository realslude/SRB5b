local function GetActorZ(actor,targ,type)
    if type == nil then type = 1 end
    if not (actor and actor.valid) then return 0 end
    if not (targ and targ.valid) then return 0 end
    
    local flip = P_MobjFlip(actor)
    
    --get z
    if type == 1
        if flip == 1
            return actor.z
        else
            return actor.z+actor.height-targ.height
        end
    --get top z
    elseif type == 2
        if flip == 1
            return actor.z+actor.height
        else
            return actor.z-targ.height
        end
    end
    return 0
end

addHook("MusicChange", function(oldname, newname)
    if splitscreen
        return
    end
    if not (consoleplayer and consoleplayer.valid)
        return
    end
    if skins[consoleplayer.skin].name == "book" or skins[consoleplayer.skin].name == "match" or skins[consoleplayer.skin].name == "icecube"
        if newname == "DISCO"
            return "TCHOA"
        end
    end
end)



freeslot("S_WINTOKEN","MT_WINTOKEN","SPR_WNTK")

freeslot("S_BOOK_HURRYUP")

function A_SetPAnim(mo, var1, var2)
	if not (mo.player and mo.player.valid)
	or var1 == nil then return end
	
	mo.player.panim = var1
end

states[S_BOOK_HURRYUP] = {
	sprite = SPR_PLAY,
	frame = SPR2_CNT1,
	tics = 2,
	action = A_SetPAnim,
	var1 = PA_IDLE,
	nextstate = S_BOOK_HURRYUP
}

-- code from spongebob... yay :)
-- except me (pacola) completely changed it :)
-- damn, i suck at codeing (slude) :(
addHook("PlayerThink", function(p)
    if not (p.mo and p.mo.valid)
	or (p.mo.skin ~= "book" and p.mo.skin ~= "match") return end
	
	if ((PizzaTime and PizzaTime.PizzaTime) -- checks if you're in ptopp's pizza time
	or (PTJE and PTJE.pizzatime) -- checks if you're in Jisk Edition/Spice Runners's pizza time
	or (PizzaTime and PizzaTime.sync and PizzaTime.sync.PizzaTime) -- checks if you're in PTv2's pizza time
	or (HAPPY_HOUR and HAPPY_HOUR.happyhour)) -- and checks if IT'S HAPPY HOUR
	and p.panim == PA_IDLE
	and p.mo.state ~= S_BOOK_HURRYUP
	and not p.powers[pw_super] then -- and you're not super
		p.mo.state = S_BOOK_HURRYUP
	end
end)

states[S_WINTOKEN] = {
	sprite = SPR_WNTK,
	frame = A,
	tics = -1,
}
--TODO: make this a collectable
mobjinfo[MT_WINTOKEN] = {
	doomednum = -1,
	spawnstate = S_WINTOKEN,
	flags = MF_SLIDEME|MF_NOCLIPTHING|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY,
	height = 4*FRACUNIT,
	radius = 4*FRACUNIT,
}
--chaos emeralds are replaced with spirits
local emeraldslist = {
	[0] = SKINCOLOR_GREEN,
	[1] = SKINCOLOR_SIBERITE,
	[2] = SKINCOLOR_SAPPHIRE,
	[3] = SKINCOLOR_SKY,
	[4] = SKINCOLOR_TOPAZ,
	[5] = SKINCOLOR_FLAME,
	[6] = SKINCOLOR_SLATE,
}

local function skinCheck(skin)
	skin = skins[$].name
	return (skin == "book" or skin == "icecube" or skin == "match")
end

rawset(_G, "SRB5b_skinCheck", skinCheck)

addHook("MobjThinker",function(gem)
    if not (gem and gem.valid) then return end
	if not (gem.target and gem.target.valid)
	or not skinCheck(gem.target.skin) then return end
    if emeraldslist[gem.frame & FF_FRAMEMASK] == nil then return end
    
    if not gem.emeraldcolor
        gem.emeraldcolor = emeraldslist[gem.frame & FF_FRAMEMASK]
    end
    local soda = P_SpawnMobjFromMobj(gem,0,0,0,MT_WINTOKEN)
    soda.tracer = gem.target
    soda.emeralddex = gem.frame & FF_FRAMEMASK
    P_RemoveMobj(gem)
    return
end,MT_GOTEMERALD)



addHook("MobjThinker",function(gem)
	if not (gem and gem.valid) then return end
	if emeraldslist[gem.emeralddex] == nil then P_RemoveMobj(gem) return end
	
	local me = gem.tracer
	
	if not (me and me.valid) then P_RemoveMobj(gem) return end
	
	--if not HAPPY_HOUR.gameover
	if not gem.emeraldcolor
		gem.emeraldcolor = emeraldslist[gem.emeralddex]
	end
	gem.color = gem.emeraldcolor
	if gem.timealive == nil
		gem.timealive = 0
	else
		gem.timealive = $+1
	end
	gem.circle = R_PointToAngle(gem.x,gem.y)+FixedAngle( ((2*FU)*3/2)*gem.timealive )
	
	
	local x,y = cos(gem.circle), sin(gem.circle)
	local z = sin(gem.circle)*12
	P_MoveOrigin(gem,
		me.x + 25*x,
		me.y + 25*y,
		GetActorZ(me,gem,1) + z + (7*gem.scale)
	)
	
	gem.angle = gem.circle+ANGLE_90
	
	if not camera.chase
		gem.flags2 = $|MF2_DONTDRAW
	else
		gem.flags2 = $ &~MF2_DONTDRAW
	end
end,MT_WINTOKEN)

addHook("PlayerThink", function(p)
    if not (p.mo and p.mo.valid)
	or p.mo.skin ~= "book" return end
	local takis = p.takistable
	
	if not takis return end
	takis.HUD.happyhour.its.patch = "TAHY_CAKE"
    takis.HUD.happyhour.happy.patch = "TAHY_ATAT"
    takis.HUD.happyhour.hour.patch = "TAHY_STAK"
	/*takis.HUD.happyhour.happy.patch = "TAHY_CAST"
    takis.HUD.happyhour.hour.patch = "TAHY_EXCL"*/
end)

-- book's wait and edge animations are too slow
-- let's make them faster
-- lua made by pacola for book mod srb2 :D

addHook("PlayerThink", function(p)
	if not (p.mo and p.mo.valid) then return end
	
	
	if p.mo.skin == "book" then
		if p.mo.state == S_PLAY_PAIN
		and p.mo.anim_duration > 2
			p.mo.anim_duration = 2
		elseif p.mo.state == S_PLAY_WAIT
		and p.mo.tics > 4
			p.mo.tics = 4
		elseif p.mo.state == (S_PLAY_EDGE or S_PLAY_WALK)
		and p.mo.tics > 2
			p.mo.tics = 2
		end
	elseif p.mo.skin == "match" 
	and p.mo.state == S_PLAY_EDGE then
		p.mo.tics = min($, 4)
	end
end)

// poyo
if not(kirbyabilitytable)
    rawset(_G, "kirbyabilitytable", {})
end
kirbyabilitytable[MT_BOOK_METALBOX] = 3 // metal box give stone
kirbyabilitytable["book"] = 10 //book give sword cuz cutter ability doesnt exist
kirbyabilitytable["match"] = 1 //match give fire
kirbyabilitytable["icecube"] = 2 //idk what *ice*cube gives :p