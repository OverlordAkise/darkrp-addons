--Luctus sit abuse fix
--Made by OverlordAkise

--This is based on the default "sit anywhere"
--If you move a prop then it will throw any player that is sitting on it off
--This should help against sit-prop-ghost abuse that lets players invade other people's bases

LUCTUS_SIT_CACHE = LUCTUS_SIT_CACHE or {}

hook.Add("OnPlayerSit","luctus_fix_sit",function(ply, pos, ang, parent, parentbone, vehicle)
    LUCTUS_SIT_CACHE[ply] = parent
end)

hook.Add("PlayerLeaveVehicle","luctus_fix_sit",function(ply,veh)
    if IsValid(veh) and veh:GetClass() == "prop_vehicle_prisoner_pod" then
        LUCTUS_SIT_CACHE[ply] = nil
    end
end)

hook.Add("OnPhysgunPickup","luctus_fix_sit",function(ply,ent)
    for k,v in ipairs(player.GetHumans()) do
        local vent = LUCTUS_SIT_CACHE[v]
        if vent and vent == ent then
            v:ExitVehicle()
        end
    end
end)

print("[luctus_sit_fix] sv loaded")
