--Luctus Anticheat
--Made by OverlordAkise

local STEAMID_WHITELIST = {
    ["STEAM_0:0:12345"] = true,
}

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
    print("[luctus_ac] Banning",ply:Nick(),ply:SteamID(),"(time:",length,") for",pMessage)
    if STEAMID_WHITELIST[ply:SteamID()] then {
        print("[luctus_ac] ...but he is immune")
        return
    }
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
    print("[luctus_ac] Ban done.")
    PrintMessage(HUD_PRINTTALK,"[luctus_ac] "..ply:Nick().." was banned for '"..pMessage.."'!")
    hook.Run("LuctusAC",ply:Nick(),ply:SteamID(),length,pMessage)
end

net.Receive("luctusac_change",function(len,ply)
    local conname = net.ReadString()
    local convalue = net.ReadString()
    if convalue != GetConVar(conname):GetString() then
        print("[luctus_ac] Convar mismatch",ply:Nick(),ply:SteamID(),"->",conname,":",convalue)
        LuctusAC_Punish(ply,0,"changing convar "..conname.." to "..convalue)
    end
end)

net.Receive("luctusac_caught",function(len,ply)
    local reason = net.ReadString()
    print("[luctus_ac] Caught",ply:Nick(),ply:SteamID(),"->",reason)
    LuctusAC_Punish(ply,0,reason)
end)

--anti net spam
LUCTUS_AC_NETCOUNT = LUCTUS_AC_NETCOUNT or {}
LUCTUS_AC_NETLAST = LUCTUS_AC_NETLAST or {}
LUCTUS_AC_NETBANNED = LUCTUS_AC_NETBANNED or {}
hook.Add("PlayerInitialSpawn","luctus_ac",function(ply)
    LUCTUS_AC_NETCOUNT[ply] = 0
    LUCTUS_AC_NETLAST[ply] = CurTime()
end)

local netIncoming = net.Incoming
function net.Incoming( len, ply )
    if LUCTUS_AC_NETBANNED[ply] then return end
    if LUCTUS_AC_NETLAST[ply] <= CurTime() then
        LUCTUS_AC_NETCOUNT[ply] = 0
        LUCTUS_AC_NETLAST[ply] = CurTime()+5
    end
    LUCTUS_AC_NETCOUNT[ply] = LUCTUS_AC_NETCOUNT[ply] + 1
    if LUCTUS_AC_NETCOUNT[ply] > 300 then -- >1 net/tick if 66ticks
        print("[luctus_ac] Net spam detected from",ply:Nick(),ply:SteamID())
        LuctusAC_Punish(ply,0,"net spam")
        LUCTUS_AC_NETBANNED[ply] = true
    end
    netIncoming(len,ply)
end

hook.Add("PlayerDisconnected","luctus_ac_cleanup",function(ply)
    LUCTUS_AC_NETCOUNT[ply] = nil
    LUCTUS_AC_NETLAST[ply] = nil
    LUCTUS_AC_NETBANNED[ply] = nil
end)

--Small "menu check" bonanza
local function netKick(msg,ply)
    print("[WARNING] "..ply:Nick().."("..ply:SteamID()..") tried to send an exploit net message: "..msg)
    hook.Run("LuctusACNetDetected",ply,msg)
    ply:Kick("suspicion of exploiting")
end

local net_msg_list = {
    "update_store_freebodygroupr",
    "announcementadmin",
    "StandPose_Server",
}

for k,msg in ipairs(net_msg_list) do
    util.AddNetworkString(msg)
    net.Receive(msg,function(len,ply) netKick(msg,ply) end)
end

print("[luctus_ac] sv loaded")
