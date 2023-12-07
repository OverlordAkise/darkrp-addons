--Luctus UseOnMapstart
--Made by OverlordAkise

--This script uses buttons or opens doors on severstart and map cleanups

--A number means "find entity by MapCreationID"
--A text means "find entity by name"

--We "use" (=press [E]) on these entities
local buttons = {
    4318,
    "lcz_breachbutton",
}

--We fire "open" event on these entities
local doors = {
    1465,
    "lcz_door",
}


function LuctusUseOnMapstart()
timer.Simple(1,function()
    for k,v in ipairs(buttons) do
        print("[luctus_useonmapstart] Pressing button:",v)
        local ent = nil
        if type(v) == "string" then
            if ents.FindByName(v)[1] and IsValid(ents.FindByName(v)[1]) then
                ent = ents.FindByName(v)[1] --entity0=worldspawn
            end
        else
            if IsValid(ents.GetMapCreatedEntity(v)) then
                ent = ents.GetMapCreatedEntity(v)
            end
        end
        if not IsValid(ent) then
            print("[luctus_useonmapstart] Error using button!:",v)
            continue
        end
        ent:Use(Entity(0))
    end
    for k,v in ipairs(doors) do
        print("[luctus_useonmapstart] Opening door:",v)
        local ent = nil
        if type(v) == "string" then
            if ents.FindByName(v)[1] and IsValid(ents.FindByName(v)[1]) then
                ent = ents.FindByName(v)[1]
            end
        else
            if IsValid(ents.GetMapCreatedEntity(v)) then
                ent = ents.GetMapCreatedEntity(v)
            end
        end
        if not IsValid(ent) then
            print("[luctus_useonmapstart] Error opening door!:",v)
            continue
        end
        --SCP Doors fix if the prop infront of the door was added
        if ent:GetClass() == "prop_dynamic" and ent:GetParent() and IsValid(ent:GetParent()) and ent:GetParent():GetClass() == "func_door" then
            ent = ent:GetParent()
        end
        ent:keysUnLock()
        ent:Fire("open","",0.5)
        ent:Fire("setanimation","open",0.5)
    end
end)
end

hook.Add("PostCleanupMap","luctus_useonmapstart",LuctusUseOnMapstart)
hook.Add("InitPostEntity","luctus_useonmapstart",LuctusUseOnMapstart)

print("[luctus_useonmapstart] sv loaded")
