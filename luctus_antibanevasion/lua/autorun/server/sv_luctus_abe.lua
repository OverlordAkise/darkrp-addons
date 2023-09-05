--Luctus Anti Ban Evasion
--Made by OverlordAkise

util.AddNetworkString("luctus_abe_checkid")

LUCTUS_ABE_IP_LIST = {}
LUCTUS_ABE_IP_PROXYS = {}

net.Receive("luctus_abe_checkid",function(len,ply)
    local sentSteamID = net.ReadString()
    --sentSteamID = "1" --Testing, DEBUG
    if not sentSteamID or sentSteamID == "" then
        LuctusAbeEcho(LUCTUS_ABE_NO_CHECK_SENT,ply,"The SteamID of player "..ply:SteamName().." ("..ply:SteamID()..") wasn't received properly.")
        return
    end
    if ply:SteamID() ~= sentSteamID then
        LuctusAbeEcho(LUCTUS_ABE_SECOND_ACCOUNT,ply,"The SteamID of player "..ply:SteamName().." ("..ply:SteamID()..") is different than the saved one ("..sentSteamID..")")
    end
end)

hook.Add("PlayerInitialSpawn","luctus_abe_checkfamily",function(ply)
    --IP of another player
    LuctusAbeCheckDoubleIPs(ply)
    --IP of proxy/vpn
    LuctusAbeCheckProxyIP(ply)
    --Family sharing
    LuctusAbeCheckFamilySharing(ply)
    --Check country / vpn
    LuctusAbeCheckCountry(ply)
end)

function LuctusAbeEcho(level,ply,message)
    print("[banevasion]",message)
    hook.Run("LuctusAntiBanEvasionDetection",ply,level,message)
    if level == 1 then
        ply:Kick()
    elseif level >= 2 then
        RunConsoleCommand("ulx", "banid", ply:SteamID(), "0", "Trying to circumvent a ban.")
    end
    for k,v in pairs(player.GetAll()) do
        if LUCTUS_ABE_NOTIFGROUPS[v:GetUserGroup()] then
            v:PrintMessage(3,"[banevasion] "..message)
        end
    end
end

function LuctusAbeCheckFamilySharing(ply)
    local fsid = ply:OwnerSteamID64()
    if ply:SteamID64() ~= fsid then
        LuctusAbeEcho(LUCTUS_ABE_FAMILY_SHARING,ply,"The SteamID of player "..ply:SteamName().." ("..ply:SteamID64()..") is family shared (sid: "..fsid..")")
        if LUCTUS_ABE_FAMILY_SHARING > 1 then return end
        --If family-shared account is banned
        local sid = util.SteamIDFrom64(fsid)
        LuctusAbeCheckFamilyBan(sid,ply)
    end
end

function LuctusAbeCheckFamilyBan(sid,ply)
    local ban = ULib.bans[sid]
    if ban then
        LuctusAbeEcho(LUCTUS_ABE_FAMILY_SHARING_BAN,ply,"The Family-Shared Owner SteamID of player "..ply:SteamName().." ("..ply:SteamID()..") is banned, so also banning this player. (Banned SID: "..sid..")")
    end
end

function LuctusAbeCheckProxyIP(ply)
    local ip = string.Explode(":",ply:IPAddress())[1]
    if LUCTUS_ABE_IP_PROXYS[ip] then
        LuctusAbeEcho(LUCTUS_ABE_PROXY_IP,ply,"The Player "..ply:SteamName().." ("..ply:SteamID()..") has an IP of a known proxy server. (IP: "..ip..", Proxy: "..LUCTUS_ABE_IP_PROXYS[ip]..")")
    end
end

function LuctusAbeCheckDoubleIPs(ply)
    local sid = ply:SteamID()
    local ip = string.Explode(":",ply:IPAddress())[1]
    if not LUCTUS_ABE_IP_LIST[ip] then
        LUCTUS_ABE_IP_LIST[ip] = sid
        return
    end
    if LUCTUS_ABE_IP_LIST[ip] and LUCTUS_ABE_IP_LIST[ip] ~= sid then
        LuctusAbeEcho(LUCTUS_ABE_IP_DIFFERENT_SID,ply,"The player "..ply:SteamName().." ("..ply:SteamID()..") joined with an IP that another steamid used. (IP: "..ip..",SID: "..LUCTUS_ABE_IP_LIST[ip]..")")
    end
end

function LuctusAbeCheckCountry(ply)
    local ip = string.Explode(":",ply:IPAddress())[1]
    if ip == "loopback" or ip == "Error!" then return end --local game or bot
    http.Fetch("http://ip-api.com/json/"..ip,function(body)
        data = util.JSONToTable(body)
        if not data.status or data.status ~= "success" then
            ErrorNoHaltWithStack("IP API failed!")
            return
        end
        LuctusAbeEcho(0,ply,ply:SteamName().." ("..ply:SteamID()..") joined with an IP from '"..data.country.."' (ip:"..ip..",isp:"..data.isp..",org:"..data.org..")")
        if not LUCTUS_ABE_IP_OK_COUNTRIES[data.country] then
            if not IsValid(ply) then return end --already kicked
            LuctusAbeEcho(LUCTUS_ABE_IP_FOREIGN_COUNTRY,ply,ply:SteamName().." ("..ply:SteamID()..") joined with an IP from '"..data.country.."'")
        end
    end)
end

hook.Add("Tick","luctus_abe_ip_load",function()
    local ss = SysTime()
    print("[luctus_abe] Starting to load proxy ip list...")
    http.Fetch("https://api-www.mullvad.net/www/relays/all/",function(b)
        for k,v in pairs(util.JSONToTable(b)) do
            if v.ipv4_addr_in then LUCTUS_ABE_IP_PROXYS[v.ipv4_addr_in] = "mul" end
            if v.ipv6_addr_in then LUCTUS_ABE_IP_PROXYS[v.ipv6_addr_in] = "mul" end
            if v.ipv4_v2ray then LUCTUS_ABE_IP_PROXYS[v.ipv4_v2ray] = "mul" end
        end
        print("[luctus_abe] loaded mullvad proxy ip list!")
    end)
    http.Fetch("https://check.torproject.org/torbulkexitlist",function(b)
        for k,v in pairs(string.Explode("\n",b)) do
            LUCTUS_ABE_IP_PROXYS[v] = "tor"
        end
        print("[luctus_abe] loaded tor proxy ip list!")
    end)
    hook.Remove("Tick","luctus_abe_ip_load")
end)

print("[luctus_antibanevasion] sv loaded")
