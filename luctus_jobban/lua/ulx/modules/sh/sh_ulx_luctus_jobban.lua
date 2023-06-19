--Luctus Jobban ULX
--Made by OverlordAkise

local luctus_job_cache = luctus_job_cache or {}

hook.Add("InitPostEntity","luctus_jobban_ulx_load",function()
	for k, v in pairs(RPExtraTeams) do
		luctus_job_cache[k] = v.name
	end
end)


function ulx.jobban(calling_ply, target_ply, jobname, time, shouldUnban)
    if not shouldUnban then
        LuctusJobbanBan(target_ply, jobname, time)
        ulx.fancyLogAdmin(calling_ply, false, "#A has banned #T for #s from job #s", target_ply, time, jobname)
    else
        LuctusJobbanUnban(target_ply, jobname)
        ulx.fancyLogAdmin(calling_ply, false, "#A has unbanned #T from job #s", target_ply, jobname)
    end
end
local jobban = ulx.command("Jobban", "ulx jobban", ulx.jobban, "!jobban", true, false, true)
jobban:defaultAccess( ULib.ACCESS_SUPERADMIN )
jobban:addParam{ type=ULib.cmds.PlayerArg }
jobban:addParam{ type=ULib.cmds.StringArg, completes=luctus_job_cache, ULib.cmds.restrictToCompletes }
jobban:addParam{ type=ULib.cmds.NumArg, min=0, max=9999999999, default=0, hint="Time in seconds, 0=infinite", ULib.cmds.optional, ULib.cmds.round }
jobban:addParam{ type=ULib.cmds.BoolArg, invisible=true }
jobban:help("Ban or unban a player from a job")
jobban:setOpposite("ulx unjobban", {_, _, _, _, true}, "!unjobban")


function ulx.jobbanid(calling_ply, steamid, jobname, time, shouldUnban)
    if not shouldUnban then
        LuctusJobbanBanID(steamid, jobname, time)
        ulx.fancyLogAdmin(calling_ply, false, "#A has banned #T for #s from job #s", target_ply, time, jobname)
    else
        LuctusJobbanUnbanID(steamid, jobname)
        ulx.fancyLogAdmin(calling_ply, false, "#A has unbanned #T from job #s", target_ply, jobname)
    end
end
local jobbanid = ulx.command("Jobban", "ulx jobbanid", ulx.jobbanid, "!jobbanid", true, false, true)
jobbanid:defaultAccess( ULib.ACCESS_SUPERADMIN )
jobbanid:addParam{ type=ULib.cmds.StringArg, hint="STEAM_0:0:12345678" }
jobbanid:addParam{ type=ULib.cmds.StringArg, completes=luctus_job_cache, ULib.cmds.restrictToCompletes }
jobbanid:addParam{ type=ULib.cmds.NumArg, min=0, max=9999, default=0, hint="Time", ULib.cmds.optional, ULib.cmds.round }
jobbanid:addParam{ type=ULib.cmds.StringArg, completes=formats, ULib.cmds.restrictToCompletes }
jobbanid:addParam{ type=ULib.cmds.BoolArg, invisible=true }
jobbanid:help("Ban or unban a player via its steamid from a job")
jobbanid:setOpposite("ulx unjobbanid", {_, _, _, _, true}, "!unjobbanid")


function ulx.jobbanlist(calling_ply, steamid, shouldCleanup)
    local printFunc = function(text) print(text) end
    if IsEntity(calling_ply) and IsValid(calling_ply) and calling_ply:IsPlayer() then
        printFunc = function(text) calling_ply:PrintMessage(HUD_PRINTCONSOLE,text) end
        DarkRP.notify(calling_ply,0,5,"[jobban] Please check your console for output!")
    end
	LuctusJobbanGetBySteamID(steamid, function(data)
        if not data or table.Count(data) == 0 then
            printFunc("0 bans found for steamid "..steamid)
            return
        end
        printFunc(table.Count(data).." bans found for "..steamid)
        for k,row in pairs(data) do
            local rowUnbantime = tonumber(row.unbantime)
            local unbantime = rowUnbantime-os.time()
            if shouldCleanup and rowUnbantime ~= 0 and unbantime <= 0 then
                LuctusJobbanUnbanID(steamid, row.job)
                continue
            end
            if rowUnbantime == 0 then
                printFunc(row.job.." perma banned")
            elseif unbantime > 0 then
                printFunc(row.job.." unbanned in: "..Utime.timeToStr(unbantime))
            else
                printFunc(row.job.." is unbanned")
            end
        end
    end)
end
local jobbanlist = ulx.command("Jobban", "ulx jobbanlist", ulx.jobbanlist, "!jobbanlist", true, false, true)
jobbanlist:defaultAccess( ULib.ACCESS_SUPERADMIN )
jobbanlist:addParam{ type=ULib.cmds.StringArg, hint="SteamID" }
jobbanlist:addParam{ type=ULib.cmds.BoolArg, invisible=true }
jobbanlist:help("List the current jobbans of a steamid")
jobbanlist:setOpposite("ulx jobbancleanup", {_, _, true})

if CLIENT then
    hook.Add("LuctusLogAddCategory","luctus_jobban",function()
        table.insert(lucid_log_quickfilters,"Jobban")
    end)
end

print("[luctus_jobban] ulx loaded")
