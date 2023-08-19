
if SERVER then
    util.AddNetworkString("luctus_rules")
end

function ulx.forcerules(calling_ply,target_ply,timeToOpen,shouldClose)
    print(calling_ply,target_ply,timeToOpen,shouldClose)
    net.Start("luctus_rules")
        net.WriteInt(shouldClose and -1 or timeToOpen,16)
    net.Send(target_ply)
    ulx.fancyLogAdmin(calling_ply, "#A "..(shouldClose and "closed" or "opened").." the rules for #T",target_ply)
end
local forcerules = ulx.command("SCP", "ulx forcerules", ulx.forcerules, "!forcerules" )
forcerules:addParam{ type=ULib.cmds.PlayerArg }
forcerules:addParam{ type=ULib.cmds.NumArg, default=1, min=1, hint="Time to force open" }
forcerules:addParam{ type=ULib.cmds.BoolArg, invisible=true }
forcerules:defaultAccess( ULib.ACCESS_ADMIN )
forcerules:help("Open the rules for someone")
forcerules:setOpposite("ulx closerules", {_, _, _, true}, "!closerules")
