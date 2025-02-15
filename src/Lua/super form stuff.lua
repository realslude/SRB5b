
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
	or not SRB5b_skinCheck(p.mo.skin) return end
	
	-- super form stuff
	if p.powers[pw_super]
		p.mo.color = SKINCOLOR_YOYLEMETAL
		/*if p.mo.skin ~= "book" then
			p.mo.colorized = true
			p.srb5bsuper = true
		end
	elseif p.srb5bsuper then
		p.srb5bsuper = false
		p.mo.colorized = false*/
	end
end)

addHook("MobjThinker", function(mo)
	if (mo.target and mo.target.valid)
	and SRB5b_skinCheck(mo.target.skin)
	and mo.target.player.powers[pw_super]
	and mo.color ~= SKINCOLOR_YOYLEMETAL
		mo.color = SKINCOLOR_YOYLEMETAL
		return
	end
end, MT_GHOST)