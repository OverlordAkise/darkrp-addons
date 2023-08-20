--Luctus no-player-car-pickup
--Made by OverlordAkise

local allowedGroups = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["operator"] = true,
    ["moderator"] = true,
}

hook.Add("PhysgunPickup","luctus_anticar",function(ply, ent) 
    if (ent:IsVehicle() and allowedGroups[ply:GetUserGroup()] == nil) then 
        return false 
    end
end)

print("[luctus_anticarpickup] sv fix loaded")
