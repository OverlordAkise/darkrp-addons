--Luctus Mods-Can-Spawn-Weapons Fix
--Made by OverlordAkise

--Let's moderators and other teammembers spawn weapons

local allowedRanks = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["operator"] = true,
    ["moderator"] = true,
}

hook.Add("PlayerGiveSWEP","luctus_modweapons",function(ply,class,info)
    if allowedRanks[ply:GetUserGroup()] then
        return true
    end
    DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_spawn_weapons"))
    return false
end)

hook.Add("PlayerSpawnSWEP","luctus_modweapons",function(ply,class,info)
    if allowedRanks[ply:GetUserGroup()] then
        return true
    end
    DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_spawn_weapons"))
    return false
end)

print("[luctus_modweapons] sv loaded")
