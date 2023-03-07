--Physgun freeze players
--Made by OverlordAkise

hook.Add("PhysgunPickup","luctus_physgun_unfreeze",function(ply, ent)
    if IsValid(ent) and ent:IsPlayer() and ent:IsFrozen() then
        ent:Freeze(false)
        DarkRP.notify(ply, 3, 5, "Unfroze player!")
    end
end)

hook.Add("PhysgunDrop","luctus_physgun_freeze",function(ply,ent)
    if ent:IsPlayer() and not ent:IsFrozen() and ply:KeyDown(IN_ATTACK2) then
        timer.Simple(0.1,function()
            ent:Freeze(true)
            DarkRP.notify(ply, 3, 5, "Froze player!")
        end)
    end
end)
