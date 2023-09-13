--Luctus Watchlist ULX Module
--Made by OverlordAkise

local CATEGORY_NAME = "Utility"

-- !watchlistset
function ulx.watchlistset(calling_ply, target_ply, text)
    LuctusWatchlistSet(target_ply:SteamID64(),text)
end
local watchlistset = ulx.command( CATEGORY_NAME, "ulx watchlistset", ulx.watchlistset, "!watchlistset" )
watchlistset:addParam{ type=ULib.cmds.PlayerArg }
watchlistset:addParam{ type=ULib.cmds.StringArg, hint="Reason", ULib.cmds.takeRestOfLine }
watchlistset:defaultAccess( ULib.ACCESS_ADMIN )
watchlistset:help("Set the watchlist entry for a player")

-- !watchlistsetid
function ulx.watchlistsetid(calling_ply, steamid, text)
    LuctusWatchlistSet(steamid,text)
end
local watchlistsetid = ulx.command( CATEGORY_NAME, "ulx watchlistsetid", ulx.watchlistsetid, "!watchlistsetid" )
watchlistsetid:addParam{ type=ULib.cmds.StringArg, hint="Steamid64" }
watchlistsetid:addParam{ type=ULib.cmds.StringArg, hint="Reason", ULib.cmds.takeRestOfLine }
watchlistsetid:defaultAccess( ULib.ACCESS_ADMIN )
watchlistsetid:help("Set the watchlist entry for a player")

-- !watchlistget
function ulx.watchlistget(calling_ply, target_ply)
    local text = LuctusWatchlistGet(target_ply:SteamID64())
    if text == "" then
        LuctusWatchlistTell(calling_ply,target_ply:Nick().."("..target_ply:SteamID()..") is NOT on the watchlist!")
    else
        LuctusWatchlistTell(calling_ply,target_ply:Nick().."("..target_ply:SteamID()..") is on the watchlist! ("..text..")")
    end
end
local watchlistget = ulx.command( CATEGORY_NAME, "ulx watchlistget", ulx.watchlistget, "!watchlistget" )
watchlistget:addParam{ type=ULib.cmds.PlayerArg }
watchlistget:defaultAccess( ULib.ACCESS_ADMIN )
watchlistget:help("Get the watchlist entry of a player")

-- !watchlistgetid
function ulx.watchlistgetid(calling_ply, steamid)
    local text = LuctusWatchlistGet(steamid)
    if text == "" then
        LuctusWatchlistTell(calling_ply,steamid.." is not on the watchlist or file not found!")
    else
        LuctusWatchlistTell(calling_ply,steamid.." is on the watchlist! ("..text..")")
    end
end
local watchlistgetid = ulx.command( CATEGORY_NAME, "ulx watchlistgetid", ulx.watchlistgetid, "!watchlistgetid" )
watchlistgetid:addParam{ type=ULib.cmds.StringArg, hint="steamid64 of player" }
watchlistgetid:defaultAccess( ULib.ACCESS_ADMIN )
watchlistgetid:help("Get the watchlist entry of a steamid")

print("[luctus_watchlist] ulx loaded")
