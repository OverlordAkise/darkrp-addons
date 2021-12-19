--Luctus no-player-car-pickup
--Made by OverlordAkise

local allowedGroups = {}
allowedGroups["superadmin"] = true
allowedGroups["admin"] = true
allowedGroups["operator"] = true
allowedGroups["moderator"] = true

hook.Add("PhysgunPickup","luctus_anticar",function(ply, ent) 
  if (ent:IsVehicle() and allowedGroups[ply:GetUserGroup()] == nil) then 
    return false 
  end
end)
