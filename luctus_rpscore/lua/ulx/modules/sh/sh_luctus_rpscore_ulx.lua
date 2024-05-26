--Luctus RP-Score ULX Module
--Made by OverlordAkise

local CATEGORY_NAME = "RPScore"

-- !setrpscore
function ulx.setrpscore( calling_ply, target_ply, amount )
    target_ply:setRPScore(math.floor(amount))
    LuctusRPScoreSave(target_ply)
    ulx.fancyLogAdmin( calling_ply, true, "#A set the RP-Score of #T to #s", target_ply, amount )
end
local setrpscore = ulx.command( CATEGORY_NAME, "ulx setrpscore", ulx.setrpscore, "!setrpscore" )
setrpscore:addParam{ type=ULib.cmds.PlayerArg }
setrpscore:addParam{ type=ULib.cmds.NumArg, min=0, max=1000000, default=5, hint="RP-Score" }
setrpscore:defaultAccess( ULib.ACCESS_SUPERADMIN )
setrpscore:help( "Set the RP-Score of a player." )

-- !addrpscore
function ulx.addrpscore( calling_ply, target_ply, amount )
    target_ply:addRPScore(amount)
    LuctusRPScoreSave(target_ply)
    ulx.fancyLogAdmin( calling_ply, true, "#A added #T #s RP-Score", target_ply, amount )
end
local addrpscore = ulx.command( CATEGORY_NAME, "ulx addrpscore", ulx.addrpscore, "!addrpscore" )
addrpscore:addParam{ type=ULib.cmds.PlayerArg }
addrpscore:addParam{ type=ULib.cmds.NumArg, min=0, max=1000000, default=5, hint="RP-Score" }
addrpscore:defaultAccess( ULib.ACCESS_SUPERADMIN )
addrpscore:help( "Give RP-Score to a player." )

-- !addrpscoreid
function ulx.addrpscoreid( calling_ply, steamid, amount )
    local res = sql.Query("UPDATE luctus_rpscore SET rpscore = rpscore+"..amount.." WHERE steamid = "..sql.SQLStr(steamid))
    if res == false then
        ErrorNoHaltWithStack(sql.LastError())
    end
    ulx.fancyLogAdmin( calling_ply, true, "#A added #s #s RP-Score", steamid, amount )
end
local addrpscoreid = ulx.command( CATEGORY_NAME, "ulx addrpscoreid", ulx.addrpscoreid, "!addrpscoreid" )
addrpscoreid:addParam{ type=ULib.cmds.StringArg, hint="STEAM_0:0:12345678" }
addrpscoreid:addParam{ type=ULib.cmds.NumArg, min=0, max=1000000, default=5, hint="RP-Score" }
addrpscoreid:defaultAccess( ULib.ACCESS_SUPERADMIN )
addrpscoreid:help( "Give RP-Score to a player." )

-- !getrpscore
function ulx.getrpscore( calling_ply, target_ply )
    DarkRP.notify(calling_ply,0,5,target_ply:Nick().." has "..target_ply:getRPScore().." RP-Score." )
    calling_ply:PrintMessage(HUD_PRINTTALK,target_ply:Nick().." has "..target_ply:getRPScore().." RP-Score." )
end
local getrpscore = ulx.command( CATEGORY_NAME, "ulx getrpscore", ulx.getrpscore, "!getrpscore" )
getrpscore:addParam{ type=ULib.cmds.PlayerArg }
getrpscore:defaultAccess( ULib.ACCESS_SUPERADMIN )
getrpscore:help( "Show a players RP-Score." )

-- !getrpscoreid
function ulx.getrpscoreid( calling_ply, steamid )
    local res = sql.QueryValue("SELECT rpscore FROM luctus_rpscore WHERE steamid = "..sql.SQLStr(steamid))
    if res == false then
        error(sql.LastError())
    end
    if res == nil then
        res = 0
    end
    DarkRP.notify(calling_ply,0,5,steamid.." has "..res.." RP-Score." )
    calling_ply:PrintMessage(HUD_PRINTTALK,steamid.." has "..res.." RP-Score." )
end
local getrpscoreid = ulx.command( CATEGORY_NAME, "ulx getrpscoreid", ulx.getrpscoreid, "!getrpscoreid" )
getrpscoreid:addParam{ type=ULib.cmds.StringArg, hint="STEAM_0:0:12345678" }
getrpscoreid:defaultAccess( ULib.ACCESS_SUPERADMIN )
getrpscoreid:help( "Show a players RP-Score by steamid." )

print("[luctus_rpscore] ulx loaded!")
