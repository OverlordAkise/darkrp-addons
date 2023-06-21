--Luctus Jobban ULX
--Made by OverlordAkise

local luctus_job_cache = luctus_job_cache or {}

hook.Add("InitPostEntity","luctus_jobranks_ulx_load",function()
	for k, v in pairs(RPExtraTeams) do
		luctus_job_cache[k] = v.command
	end
end)


function ulx.jobrank(calling_ply, target_ply, isDownrank)
    local jobcommand = RPExtraTeams[target_ply:Team()].command
    if not isDownrank then
        luctusRankup(target_ply,jobcommand,calling_ply)
        ulx.fancyLogAdmin(calling_ply, false, "#A has promoted #T on job #s", target_ply, jobcommand)
    else
        luctusRankdown(target_ply,jobcommand,calling_ply)
        ulx.fancyLogAdmin(calling_ply, false, "#A has demoted #T on job #s", target_ply, jobcommand)
    end
end
local jobrank = ulx.command("Jobrank", "ulx promote", ulx.jobrank, "!apromote", true, false, true)
jobrank:defaultAccess( ULib.ACCESS_SUPERADMIN )
jobrank:addParam{ type=ULib.cmds.PlayerArg }
jobrank:addParam{ type=ULib.cmds.BoolArg, invisible=true }
jobrank:help("Rankup (or down) someones jobrank")
jobrank:setOpposite("ulx demote", {_, _, true}, "!ademote")


function ulx.jobrankid(calling_ply, steamid, jobcommand, rankid)
    local jobname = nil
    for k,v in pairs(RPExtraTeams) do
        if v.command == jobcommand then jobname = v.name break end
    end
    if not luctus_jobranks[jobname] then return end
    if not luctus_jobranks[jobname][rankid] then return end
    
    LuctusJobranksSet(steamid,jobcommand,rankid)
    ulx.fancyLogAdmin(calling_ply, false, "#A set the jobrank of #s on job #s to #s", steamid, jobcommand, rankid)
end
local jobrankid = ulx.command("Jobrank", "ulx jobrankset", ulx.jobrankid, "!jobrankset", true, false, true)
jobrankid:defaultAccess( ULib.ACCESS_SUPERADMIN )
jobrankid:addParam{ type=ULib.cmds.StringArg, hint="STEAM_0:0:12345678" }
jobrankid:addParam{ type=ULib.cmds.StringArg, completes=luctus_job_cache, ULib.cmds.restrictToCompletes }
jobrankid:addParam{ type=ULib.cmds.NumArg, default=1, min=1, hint="The rank the user should have" }
jobrankid:help("Set someones jobrank by steamid")


print("[luctus_jobrank] ulx loaded")
