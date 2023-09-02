--Luctus No Demotes
--Made by OverlordAkise

--There seems to be no config for disallowing demotions

hook.Add("canDemote","luctus_nodemote",function(ply, target, reason)
    return false, "You are not allowed to demote anyone"
end)

print("[luctus_nodemote] sv fix loaded")
