--Luctus No NPC Weapon Drop
--Made by OverlordAkise

hook.Add("PlayerDroppedWeapon","luctus_npc_no_wep_drop",function(ply,wep)
    if ply:IsNPC() and IsValid(wep) then
        wep:Remove()
    end
end)

print("[luctus_nonpcwepdrop] sv fix loaded")
