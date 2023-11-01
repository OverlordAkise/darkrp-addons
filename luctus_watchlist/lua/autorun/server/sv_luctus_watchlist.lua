--Luctus Watchlist
--Made by OverlordAkise

--This addon uses SteamID64 !

util.AddNetworkString("luctus_watchlist")

if not file.Exists("watchlist","DATA") then
    file.CreateDir("watchlist")
end

function LuctusWatchlistTellAdmins(text)
    local plys = {}
    for k,ply in ipairs(player.GetHumans()) do
        if not ply:query("ulx watchlistget") then continue end
        table.insert(plys,ply)
    end
    LuctusWatchlistTell(plys,text)
end

function LuctusWatchlistTell(ply,text)
    net.Start("luctus_watchlist")
        net.WriteString(text)
    net.Send(ply)
end

function LuctusWatchlistGet(steamid)
    if file.Exists("watchlist/"..steamid..".txt","DATA") then
        return file.Read("watchlist/"..steamid..".txt","DATA")
    end
    return ""
end

function LuctusWatchlistDelete(steamid,ply)
    file.Write("watchlist/"..steamid..".txt","")
    local name = "console"
    if IsValid(ply) then
        name = ply:Nick().."("..ply:SteamID()..")"
    end
    LuctusWatchlistTellAdmins(name.." deleted the watchlist of "..steamid)
    hook.Run("LuctusWatchlistDeleted",steamid,ply) --target,admin
end

function LuctusWatchlistSet(steamid,text,ply)
    file.Write("watchlist/"..steamid..".txt",text)
    local name = "console"
    if IsValid(ply) then
        name = ply:Nick().."("..ply:SteamID()..")"
    end
    LuctusWatchlistTellAdmins(name.." set the watchlist of "..steamid.." to '"..text.."'")
    hook.Run("LuctusWatchlistUpdated",steamid,text,ply) --target,reason,admin
end

hook.Add("PlayerInitialSpawn", "luctus_watchlist", function(ply)
    local wltext = LuctusWatchlistGet(ply:SteamID64())
    if wltext ~= "" then
        LuctusWatchlistTellAdmins(ply:Nick().."("..ply:SteamID()..") is on the watchlist! ("..wltext..")")
        hook.Run("LuctusWatchlistJoined",ply)
    end
end)

print("[luctus_watchlist] sv loaded")
