--Luctus Technician
--Made by OverlordAkise

util.AddNetworkString("luctus_technician_repair")
util.AddNetworkString("luctus_technician_togglehud")

hook.Add("OnPlayerChangedTeam", "luctus_technician_timer", function(ply, beforeNum, afterNum)
    --switch to technician
    if team.GetName(afterNum) == LUCTUS_TECHNICIAN_JOBNAME then
        net.Start("luctus_technician_togglehud")
            net.WriteBool(true)
        net.Send(ply)
    end
    --switch from technician
    if team.GetName(beforeNum) == LUCTUS_TECHNICIAN_JOBNAME then
        net.Start("luctus_technician_togglehud")
            net.WriteBool(false)
        net.Send(ply)
    end
end)

hook.Add("InitPostEntity", "luctus_technician_breaker", function()
    timer.Create("luctus_technician_breaker",LUCTUS_TECHNICIAN_BREAK_DELAY,0,function()
        local ents = ents.FindByClass("luctus_tec*")
        local randomEnt = ents[math.random(#ents)]
        if randomEnt and IsValid(randomEnt) and not randomEnt:GetBroken() then
            randomEnt:SetBroken(true)
            --print("[luctus_technician] Sabotaged a random object!")
            hook.Run("LuctusTechnicianBroke",randomEnt)
        end
    end)
    print("[luctus_technician] Timer created!")
end)

net.Receive("luctus_technician_repair",function(len,ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) or not ent.Base == "luctus_technician_base" then return end
    if not ent:GetBroken() then return end
    if ply:GetPos():Distance(ent:GetPos()) > 512 then return end
    --reward
    ent.Hitpoints = LUCTUS_TECHNICIAN_ENT_HEALTH
    ent:SetBroken(false)
    local gainMoney = math.random(LUCTUS_TECHNICIAN_MIN_REWARD,LUCTUS_TECHNICIAN_MAX_REWARD)
    DarkRP.notify(ply,3,5,"You repaired the object and got "..gainMoney.."$!")
    ply:addMoney(gainMoney)
    hook.Run("LuctusTechnicianRepaired",ply,ent)
end)

print("[luctus_technician] sv loaded")
