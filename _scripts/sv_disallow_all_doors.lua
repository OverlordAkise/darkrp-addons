--Luctus Make-All-Doors-UnOwnable
--Made by OverlordAkise

--To run this execute the following in your server console:
--[[
    lua_run LuctusUnOwnAllDoors()
--]]

function LuctusUnOwnAllDoors()
    ownableDoors = {
        ["func_door"] = true,
        ["func_door_rotating"] = true,
        ["prop_door_rotating"] = true
    }

    for k,v in pairs(ents.GetAll()) do
        if ownableDoors[v:GetClass()] then
            v:setKeysNonOwnable(true)
            DarkRP.storeDoorData(v)
            DarkRP.storeDoorGroup(v, nil)
            DarkRP.storeTeamDoorOwnability(v)
        end
    end
end
