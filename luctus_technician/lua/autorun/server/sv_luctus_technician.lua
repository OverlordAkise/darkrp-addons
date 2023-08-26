--Luctus Technician
--Made by OverlordAkise

util.AddNetworkString("luctus_technician_repair")
util.AddNetworkString("luctus_technician_togglehud")

hook.Add("OnPlayerChangedTeam", "luctus_technician_timer", function(ply, beforeNum, afterNum)
    --switch to technician
    if RPExtraTeams[afterNum].name == LUCTUS_TECHNICIAN_JOBNAME then
        net.Start("luctus_technician_togglehud")
        net.WriteBool(true)
        net.Send(ply)
    end
    --switch from technician
    if RPExtraTeams[beforeNum].name == LUCTUS_TECHNICIAN_JOBNAME then
        net.Start("luctus_technician_togglehud")
        net.WriteBool(false)
        net.Send(ply)
    end
end)

hook.Add("InitPostEntity", "luctus_technician_breaker", function()
    timer.Create("luctus_technician_breaker",LUCTUS_TECHNICIAN_BREAK_DELAY,0,function()
        local ents = ents.FindByClass( "luctus_tec*" )
        local randomEnt = ents[math.random(#ents)]
        if randomEnt and IsValid(randomEnt) and not randomEnt:GetBroken() then
            randomEnt:SetBroken(true)
            --print("[luctus_technician] Sabotaged a random object!")
            hook.Run("LuctusTechnicianBroke",randomEnt)
        end
    end)
    print("[luctus_technician] Timer created!")
end)

print("[luctus_technician] sv loaded")
