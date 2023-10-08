--Luctus Admin-Only-Prop-Spawning Fix
--Made by OverlordAkise

--This allows admins and teammembers to spawn props

local allowedRanks = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["operator"] = true,
    ["moderator"] = true,
}

hook.Add("PlayerSpawnProp","luctus_modprops",function(ply,model)
    if not allowedRanks[ply:GetUserGroup()] then return false end
end)

print("[luctus_adminonlyprops] sv loaded")
