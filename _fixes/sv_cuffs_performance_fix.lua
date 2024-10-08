--Luctus Cuffs Performance Improvement
--Made by OverlordAkise

--by default the cuffs addon creates unnecessary server load

local vector_cache1 = Vector(0,0,20)
local vector_cache2 = Vector(0,0,5)
hook.Add("InitPostEntity","luctus_cuffs",function()

hook.Add("Think", "Cuffs ForceJump CleanupTieHooks", function()
	for _,v in ipairs(player.GetHumans()) do
		if not v.Cuff_ForceJump then continue end
        if not v:OnGround() then continue end
        local plygetpos = v:GetPos()
        local tr = util.TraceLine( {start = plygetpos, endpos = plygetpos+vector_cache1, filter = v} )
        if tr.Hit then continue end
        
        v:SetPos(plygetpos+vector_cache2 )
        
        v.Cuff_ForceJump = nil
	end
	
	if CurTime()<(NextTieHookCleanup or 0) then return end
    NextTieHookCleanup = CurTime()+3
    for _,v in ipairs(ents.FindByClass("prop_physics")) do
        if not v.IsHandcuffHook or not v.TiedHandcuffs then continue end
        for i=#v.TiedHandcuffs,0,-1 do
            if not IsValid(v.TiedHandcuffs[i]) then
                table.remove( v.TiedHandcuffs, i )
            end
        end
        if #v.TiedHandcuffs<=0 then
            v:Remove()
            continue
        end
    end
end)

print("[luctus_cuffs_performance] hook overwritten")

end)

print("[luctus_cuffs_performance] loaded")
