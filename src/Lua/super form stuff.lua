
-- right now it's just uh making the character
-- use the custom color

freeslot("SKINCOLOR_YOYLEMETAL")

skincolors[SKINCOLOR_YOYLEMETAL] = {
	name = "YoyleMetal", -- i'm not even sure if this is the correct way to write it
	ramp = {18,18,18,18,21,21,21,21,21,18,24,24,24,21,21,21},
	invcolor = SKINCOLOR_AETHER,
	invshade = 9,
	chatcolor = V_GRAYMAP,
	accessible = false
}

addHook("PlayerThink", function(p)
    if not (p.mo and p.mo.valid)
	or not SRB5b_skinCheck(p.mo.skin)
		if p.bookcolorized then
			p.bookcolorized = false
			p.mo.eflags = $ & ~MFE_FORCESUPER
			p.mo.colorized = false
		end
		return
	end
	
	local skin = skins[p.mo.skin]
	-- super form stuff
	if p.powers[pw_super]
	or (p.mo.color >= skin.supercolor and p.mo.color <= skin.supercolor+4) then
		p.mo.color = SKINCOLOR_YOYLEMETAL
	end
	
	if p.mo.skin ~= "icecube"
	and p.mo.health > 0 -- if you're
	and p.playerstate == PST_LIVE -- actually alive
	and ( (p.powers[pw_shield] & SH_FIREFLOWER)
	or mapheaderinfo[gamemap]
	and (mapheaderinfo[gamemap].typeoflevel & TOL_MARIO)
	and p.powers[pw_invulnerability] ) then
		local header = mapheaderinfo[gamemap]
		
		p.bookcolorized = true
		p.mo.colorized = true
		p.mo.eflags = $|MFE_FORCESUPER
	elseif p.bookcolorized then
		p.mo.colorized = false
		p.mo.eflags = $ & ~MFE_FORCESUPER
		p.bookcolorized = false
	end
end)

addHook("MobjThinker", function(mo)
	if not (mo.target and mo.target.valid)
	or not SRB5b_skinCheck(mo.target.skin) then return end
	
	local skin = skins[mo.target.skin]
	if ( mo.target.player.powers[pw_super]
	or mo.target.color >= skin.supercolor and mo.target.color <= skin.supercolor+4 )
	and mo.color ~= SKINCOLOR_YOYLEMETAL then
		mo.color = SKINCOLOR_YOYLEMETAL
		return
	end
end, MT_GHOST)