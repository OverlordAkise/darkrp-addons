--Luctus Mods-Can-Spawn-Entities Fix
--Made by OverlordAkise

--Let's moderators and other teammembers spawn entities

local allowedRanks = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["operator"] = true,
    ["moderator"] = true,
}

hook.Add("PlayerSpawnSENT","luctus_modentities",function(ply,class,info)
    if allowedRanks[ply:GetUserGroup()] then
        return true
    end
    DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_admin", DarkRP.getPhrase("gm_spawnsent")))
    return false
end)

print("[luctus_modentities] sv loaded")
