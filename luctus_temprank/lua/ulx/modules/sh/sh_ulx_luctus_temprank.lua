
function ulx.temprank(calling_ply, target_ply, rankname, duration)
    if not IsValid(target_ply) then return end
    if not ULib.ucl.groups[rankname] then
        ULib.tsayError( calling_ply, "This rank does not exist!", true )
        return
    end
    local seconds = duration*60
    LuctusTemprankActivate(target_ply,rankname,seconds,target_ply:GetUserGroup(),calling_ply)
	ulx.fancyLogAdmin(calling_ply, "#A gave #T the temporary rank #s for #s", target_ply, rankname, string.NiceTime(seconds))
end
local temprank = ulx.command("Utility", "ulx temprank", ulx.temprank, "!temprank")
temprank:addParam{ type=ULib.cmds.PlayerArg }
temprank:addParam{ type=ULib.cmds.StringArg, hint="donator" }
temprank:addParam{ type=ULib.cmds.NumArg, min=1, max=99999, default=2, hint="Time in minutes", ULib.cmds.round }
temprank:defaultAccess(ULib.ACCESS_ADMIN)
temprank:help("Give someone a rank only temporary")


function ulx.untemprank(calling_ply, target_ply)
    if not IsValid(target_ply) then return end
    LuctusTemprankRemove(target_ply,calling_ply)
	ulx.fancyLogAdmin(calling_ply, "#A removed the temporary rank of #T", target_ply)
end
local untemprank = ulx.command("Utility", "ulx untemprank", ulx.untemprank, "!untemprank")
untemprank:addParam{ type=ULib.cmds.PlayerArg }
untemprank:defaultAccess(ULib.ACCESS_ADMIN)
untemprank:help("Remove someones temporary rank")


function ulx.temprankid(calling_ply, steamid, rankname, duration)
    if not ULib.ucl.groups[rankname] then
        ULib.tsayError( calling_ply, "This rank does not exist!", true )
        return
    end
    local seconds = duration*60
    LuctusTemprankActivateSteamID(steamid,rankname,seconds,target_ply:GetUserGroup(),calling_ply)
	ulx.fancyLogAdmin(calling_ply, "#A gave #s the temporary rank #s for #s", steamid, rankname, string.NiceTime(seconds))
end
local temprankid = ulx.command("Utility", "ulx temprankid", ulx.temprankid, "!temprankid")
temprankid:addParam{ type=ULib.cmds.StringArg, hint="STEAM_0:0:12345" }
temprankid:addParam{ type=ULib.cmds.StringArg, hint="donator" }
temprankid:addParam{ type=ULib.cmds.NumArg, min=1, max=99999, default=2, hint="Time in minutes", ULib.cmds.round }
temprankid:defaultAccess(ULib.ACCESS_ADMIN)
temprankid:help("Give someone a rank only temporary by steamid")


function ulx.untemprankid(calling_ply, steamid)
    LuctusTemprankRemoveSteamID(steamid,calling_ply)
	ulx.fancyLogAdmin(calling_ply, "#A removed the temporary rank of #s", steamid)
end
local untemprankid = ulx.command("Utility", "ulx untemprankid", ulx.untemprankid, "!untemprankid")
untemprankid:addParam{ type=ULib.cmds.StringArg }
untemprankid:defaultAccess(ULib.ACCESS_ADMIN)
untemprankid:help("Remove someones temporary rank by steamid")
