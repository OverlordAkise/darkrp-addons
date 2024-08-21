--Luctus Spawn Restrictions
--Made by OverlordAkise

--This script lets you restrict what entities / weapons a player is allowed to spawn / pickup

--List of restricted ents and weapons
local LUCTUS_RESTRICTED_ENTS_WEPS = {
    ["m9k_acr"] = true,
    ["sent_ball"] = true,
}

--Which usergroups/ranks are allowed to spawn these anyways
local LUCTUS_RESTRICTED_WHITELIST_RANKS = {
    ["superadmin"] = true,
    ["admin"] = true,
}


hook.Add("PlayerCanPickupWeapon", "luctus_restriction", function(ply,wep)
    if LUCTUS_RESTRICTED_WHITELIST_RANKS[ply:GetUserGroup()] then return end
    if LUCTUS_RESTRICTED_ENTS_WEPS[wep:GetClass()] then
        print("[luctus_restrictions] "..ply:Nick().."("..ply:SteamID()..") tried to pickup "..wep:GetClass())
		return false
	end
end)

hook.Add("PlayerSpawnSENT", "luctus_restriction", function(ply,sent)
    if LUCTUS_RESTRICTED_WHITELIST_RANKS[ply:GetUserGroup()] then return end
    if LUCTUS_RESTRICTED_ENTS_WEPS[sent] then
        print("[luctus_restrictions] "..ply:Nick().."("..ply:SteamID()..") tried to spawn "..sent)
		return false
	end
end)

print("[luctus_restrictions] sv loaded")
