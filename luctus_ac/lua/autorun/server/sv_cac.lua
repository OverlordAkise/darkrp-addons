--Luctus Anticheat
--Made by OverlordAkise

util.AddNetworkString("luctusac_change")
util.AddNetworkString("luctusac_caught")

--Disable cheating by DarkRP
hook.Add("PostGamemodeLoaded","luctus_disable_cslua",function()
    RunConsoleCommand("sv_allowcslua","0")
    GAMEMODE.Config.disallowClientsideScripts = true
    timer.Simple(30,function()
        RunConsoleCommand("sv_allowcslua","0")
        GAMEMODE.Config.disallowClientsideScripts = true
    end)
end)

--bantime length = minutes
function LuctusAC_Punish(ply, length, pMessage)
    print("[luctus_ac] [punish] Banning",ply:Nick(),ply:SteamID(),"(time:",length,") for",pMessage)
    if not IsValid(ply) then return end
    if ply.isAlreadyBanned then return end
    ply.isAlreadyBanned = true
    if ulx then
        ULib.ban( ply, length, pMessage )
    elseif xAdmin then
        xAdmin.RegisterNewBan( ply, "CONSOLE", pMessage, length )
        ply:Kick( pMessage )
    elseif SAM then
        SAM.AddBan( ply:SteamID(), nil, length * 60, pMessage )
    else
        ply:Ban( length, false )
        ply:Kick( pMessage )
    end
    print("[luctus_ac] [punish] Ban done.")
    PrintMessage(HUD_PRINTTALK,"[luctus_ac] "..ply:Nick().." was banned for '"..pMessage.."'!")
    hook.Run("LuctusAC",ply:Nick(),ply:SteamID(),length,pMessage)
end

net.Receive("luctusac_change",function(len,ply)
    local conname = net.ReadString()
    local convalue = net.ReadString()
    if convalue != GetConVar(conname):GetString() then
        print("[luctus_ac] [luctusac_change] Received net msg",ply:Nick(),ply:SteamID(),"->",conname,":",convalue)
        LuctusAC_Punish(ply,0,"changing convars")
    end
end)

net.Receive("luctusac_caught",function(len,ply)
    local reason = net.ReadString()
    print("[luctus_ac] [luctusac_caught] Received net msg",ply:Nick(),ply:SteamID(),"->",reason)
    LuctusAC_Punish(ply,0,"cheating")
end)

--anti net spam
hook.Add("PlayerInitialSpawn","luctus_ac",function(ply)
    ply.netCount = 0
    ply.netLast = CurTime()
end)

local netIncoming = net.Incoming
function net.Incoming( len, ply )
    if ply.netBanned then return end
    if (ply.netLast + 5) <= CurTime() then
        ply.netCount = 0
        ply.netLast = CurTime()
    end
    ply.netCount = ply.netCount + 1
    if ply.netCount > 500 then --more than 1 netmsg per tick for 5seconds
        print("[luctus_ac] [net_spam] Detected:",ply:Nick(),ply:SteamID(),"->",ply.netCount,"net messages in 5s")
        LuctusAC_Punish(ply,0,"net spam")
        ply.netBanned = true
    end
    netIncoming(len,ply)
end

print("[luctus_ac] Serverside loaded!")
