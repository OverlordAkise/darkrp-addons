--Luctus PressButtonsFromConsole
--Made by OverlordAkise

concommand.Add("pressbutton", function(ply,cmd,args,argStr)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    for k,v in ipairs(args) do
        local ent = v
        if tonumber(v) then
            ent = tonumber(v)
        end
        if type(ent) == "string" then
            local dent = ents.FindByName(ent)[1]
            if not dent or not IsValid(dent) then
                print("[pressbutton] ERROR: Not found",ent)
                continue
            end
            dent:Use(Entity(0)) --entity0=worldspawn
        else
            local dent = ents.GetMapCreatedEntity(ent)
            if not dent or not IsValid(dent) then
                print("[pressbutton] ERROR: Not found",ent)
                continue
            end
            dent:Use(Entity(0))
        end
        print("[pressbutton] Pressed:",ent)
    end
end)

print("[luctus_pressbuttons] sv loaded")
