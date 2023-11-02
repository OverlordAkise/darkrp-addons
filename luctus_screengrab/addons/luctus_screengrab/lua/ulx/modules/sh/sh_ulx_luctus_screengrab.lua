
function ulx.screengrab(calling_ply, target_ply)
    if not IsValid(target_ply) then return end
    LuctusSceneStart(target_ply,calling_ply)
    --ulx.fancyLogAdmin(calling_ply, "#A gave #T the temporary rank #s for #s", target_ply, rankname, string.NiceTime(seconds))
end
local screengrab = ulx.command("Utility", "ulx screengrab", ulx.screengrab, "!screengrab")
screengrab:addParam{ type=ULib.cmds.PlayerArg }
screengrab:defaultAccess(ULib.ACCESS_ADMIN)
screengrab:help("View someone's screen")
