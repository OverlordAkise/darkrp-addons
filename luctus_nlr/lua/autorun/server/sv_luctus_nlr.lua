--Luctus NLR
--Made by OverlordAkise

util.AddNetworkString("luctus_nlr_greyscreen")
util.AddNetworkString("luctus_nlr_showzone")

function LuctusNlrHandleDeath(ply)
    if ply.nlrzone and IsValid(ply.nlrzone) then
        ply.nlrzone:Remove()
    end
    local ent = ents.Create("nlr_zone")
    ent.player = ply
    ply.nlrzone = ent
    ent:SetPos(ply:GetPos())
    ent:Spawn()
    --luctusStartNLRTimer(ply)
    timer.Simple(0.5,function()
        net.Start("luctus_nlr_showzone")
            net.WriteEntity(ent)
        net.Send(ply)
    end)
    --Remove NLR timer:
    timer.Create(ply:SteamID().."_nlrzone",LUCTUS_NLR_DURATION,1,function()
        if not IsValid(ply) or not IsValid(ply.nlrzone) then return end
        LuctusNLRClear(ply)
    end)
    hook.Run("LuctusNLRStart",ply,LUCTUS_NLR_DURATION,CurTime()+LUCTUS_NLR_DURATION)
end

hook.Add("MedicSys_PlayerDeath","luctus_nlr_set_gd",LuctusNlrHandleDeath)
hook.Add("PostPlayerDeath","luctus_nlr_set",LuctusNlrHandleDeath)

function LuctusNLRClear(ply)
    ply.nlrzone:Remove()
    LuctusNLRReturnWeapons(ply)
    DarkRP.notify(ply,0,3,"[nlr] Your nlr has been cleared")
    hook.Run("LuctusNLREnd",ply)
end

function LuctusNLRReturnWeapons(ply)
    net.Start("luctus_nlr_greyscreen")
        net.WriteBool(false)
    net.Send(ply)
    if not ply.nlrweapons or #ply.nlrweapons == 0 then return end
    for k,v in pairs(ply.nlrweapons) do
        ply:Give(v)
    end
    ply.nlrweapons = {}
end

function LuctusNLRTakeWeapons(ply)
    net.Start("luctus_nlr_greyscreen")
        net.WriteBool(true)
    net.Send(ply)
    ply.nlrweapons = {}
    for k,v in pairs(ply:GetWeapons()) do
        table.insert(ply.nlrweapons,v:GetClass())
    end
    ply:StripWeapons()
end

hook.Add("PlayerSay","luctus_nlr_clear",function(ply,text)
    if not LUCTUS_NLR_ADMINS[ply:GetUserGroup()] then return end
    if not string.StartsWith(text,LUCTUS_NLR_REMCMD) then return end
    local plyname = string.Split(text,LUCTUS_NLR_REMCMD)[2]
    plyname = string.Trim(plyname):lower()
    local target = nil
    for k,v in ipairs(player.GetAll()) do
        if not string.find(v:Nick():lower(),plyname) then continue end
        if target ~= nil then
            DarkRP.notify(ply,1,5,"[nlr] ERROR: Too many players found.")
            return
        end
        target = v
    end
    if not target then
        DarkRP.notify(ply,1,5,"[nlr] ERROR: No player found")
        return
    end
    LuctusNLRClear(target)
    DarkRP.notify(ply,0,3,"[nlr] Target has been cleared of nlr")
end)

print("[luctus_nlr] sv loaded")
